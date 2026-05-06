//
//  ContentView.swift
//  ARPhysicsApp
//
//  Created by Mayur Tanna on 04/04/25.
//

import SwiftUI
import RealityKit
import ARKit

// MARK: - AR Session Manager
class ARSessionManager: NSObject, ObservableObject, ARSessionDelegate {
    let arView: ARView
    // Track mesh anchors for LiDAR scanning
    private var meshAnchors: [UUID: AnchorEntity] = [:]
    // Throttle mesh updates to avoid overloading
    private var lastMeshUpdate: [UUID: Date] = [:]
    private let meshUpdateThrottle: TimeInterval = 0.5 // Update at most every 0.5 seconds
    private let maxMeshAnchors = 50 // Limit total mesh anchors to prevent memory issues

    override init() {
        arView = ARView(frame: .zero)
        super.init()
        setupARSession()
    }

    private func setupARSession() {
        // Configure AR session with mesh reconstruction
        let config = ARWorldTrackingConfiguration()

        // Enable scene reconstruction for mesh-based scanning (requires LiDAR)
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
            print("✅ LiDAR mesh scanning enabled")
        } else {
            print("⚠️ LiDAR not supported - mesh scanning unavailable")
        }

        // Set delegate to handle mesh updates
        arView.session.delegate = self
        arView.session.run(config)

        // Enable physics collision with scanned geometry
        arView.environment.sceneUnderstanding.options.insert(.physics)
        arView.environment.sceneUnderstanding.options.insert(.collision)

        // Show mesh overlay for debugging
        arView.debugOptions.insert(.showSceneUnderstanding)
    }

    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                handleMeshAnchor(meshAnchor)
            }
        }
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                handleMeshAnchor(meshAnchor)
            }
        }
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                removeMeshVisualization(for: meshAnchor)
            }
        }
    }

    private func removeMeshVisualization(for meshAnchor: ARMeshAnchor) {
        let meshID = meshAnchor.identifier
        if let anchor = meshAnchors[meshID] {
            arView.scene.removeAnchor(anchor)
            meshAnchors.removeValue(forKey: meshID)
        }
    }

    // MARK: - LiDAR Mesh Handling
    private func handleMeshAnchor(_ meshAnchor: ARMeshAnchor) {
        let meshID = meshAnchor.identifier

        // Limit total mesh anchors to prevent memory overflow
        if meshAnchors[meshID] == nil && meshAnchors.count >= maxMeshAnchors {
            return // Skip new meshes if we're at the limit
        }

        // Throttle updates - only process if enough time has passed
        let now = Date()
        if let lastUpdate = lastMeshUpdate[meshID] {
            if now.timeIntervalSince(lastUpdate) < meshUpdateThrottle {
                return // Skip this update
            }
        }
        lastMeshUpdate[meshID] = now

        // Remove old visualization if it exists
        if let existingAnchor = meshAnchors[meshID] {
            arView.scene.removeAnchor(existingAnchor)
        }

        // Create mesh visualization (simplified, no corner detection)
        guard let meshVisualization = createMeshVisualization(from: meshAnchor) else {
            return
        }

        // Create anchor entity
        let anchorEntity = AnchorEntity(anchor: meshAnchor)
        anchorEntity.addChild(meshVisualization)
        meshAnchors[meshID] = anchorEntity
        arView.scene.addAnchor(anchorEntity)
    }

    private func createMeshVisualization(from meshAnchor: ARMeshAnchor) -> ModelEntity? {
        let meshGeometry = meshAnchor.geometry

        // Create mesh descriptor
        var meshDescriptor = MeshDescriptor()

        // Convert vertices from ARGeometrySource (sample every N vertices for performance)
        let verticesSource = meshGeometry.vertices
        let verticesPointer = verticesSource.buffer.contents()
        let verticesStride = verticesSource.stride
        let verticesCount = verticesSource.count

        // Simple decimation: use every vertex for small meshes, sample for large ones
        let sampleRate = verticesCount > 1000 ? 2 : 1 // Sample every 2nd vertex if > 1000 vertices

        var positions: [SIMD3<Float>] = []
        for i in stride(from: 0, to: verticesCount, by: sampleRate) {
            let vertexPointer = verticesPointer.advanced(by: i * verticesStride)
            let vertex = vertexPointer.assumingMemoryBound(to: Float.self)
            positions.append(SIMD3<Float>(vertex[0], vertex[1], vertex[2]))
        }
        meshDescriptor.positions = MeshBuffer(positions)

        // Convert faces (triangles) - sample for large meshes
        let facesElement = meshGeometry.faces
        let facesPointer = facesElement.buffer.contents()
        let faceSampleRate = facesElement.count > 500 ? 2 : 1

        var indices: [UInt32] = []
        for i in stride(from: 0, to: facesElement.count, by: faceSampleRate) {
            let facePointer = facesPointer.advanced(by: i * facesElement.indexCountPerPrimitive * MemoryLayout<Int32>.stride)
            let face = facePointer.assumingMemoryBound(to: Int32.self)

            // Adjust indices for sampled vertices
            let idx0 = UInt32(face[0]) / UInt32(sampleRate)
            let idx1 = UInt32(face[1]) / UInt32(sampleRate)
            let idx2 = UInt32(face[2]) / UInt32(sampleRate)

            // Only add if indices are valid
            if idx0 < positions.count && idx1 < positions.count && idx2 < positions.count {
                indices.append(idx0)
                indices.append(idx1)
                indices.append(idx2)
            }
        }
        meshDescriptor.primitives = .triangles(indices)

        // Skip normals for performance - they're not critical for semi-transparent visualization

        // Create mesh resource
        guard let meshResource = try? MeshResource.generate(from: [meshDescriptor]) else {
            return nil
        }

        // Create simple semi-transparent material for visualization
        var material = UnlitMaterial()
        material.color = .init(tint: UIColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.2))
        material.blending = .transparent(opacity: 1.0)

        let modelEntity = ModelEntity(mesh: meshResource, materials: [material])

        // Simplified collision - let ARKit handle physics internally
        // Only add basic collision, no expensive convex hull generation
        modelEntity.components.set(CollisionComponent(
            shapes: [.generateBox(size: [0.1, 0.1, 0.1])], // Placeholder, ARKit manages real collision
            mode: .default
        ))

        return modelEntity
    }

    // MARK: - Ball Spawning
    func spawnBall(material: BallMaterial) {
        let radius: Float = 0.05
        let mesh = MeshResource.generateSphere(radius: radius)
        var visualMaterial = SimpleMaterial()
        visualMaterial.color = .init(tint: UIColor(material.color))
        visualMaterial.roughness = .float(material.roughness)
        visualMaterial.metallic = .float(material.isMetallic ? 1.0 : 0.0)
        let entity = ModelEntity(mesh: mesh, materials: [visualMaterial])
        entity.name = "ball"

        // Add physics components with material-specific properties
        let shape = ShapeResource.generateSphere(radius: radius)
        entity.components.set(PhysicsBodyComponent(
            shapes: [shape],
            mass: material.mass,
            material: .generate(friction: material.friction, restitution: material.restitution),
            mode: .dynamic
        ))

        entity.components.set(CollisionComponent(
            shapes: [shape],
            mode: .default
        ))

        // Drop from fixed height in front of camera
        let cameraTransform = arView.cameraTransform
        let forward = cameraTransform.matrix.columns.2
        let position = cameraTransform.translation - SIMD3<Float>(forward.x, forward.y, forward.z) * 0.5
        let dropPosition = SIMD3<Float>(position.x, position.y + 0.3, position.z)

        // Add to scene
        let anchor = AnchorEntity(world: dropPosition)
        anchor.addChild(entity)
        entity.position = SIMD3<Float>(0, 0, 0)
        arView.scene.addAnchor(anchor)
    }
}

// MARK: - Content View
struct ContentView: View {
    @StateObject private var arManager = ARSessionManager()
    @State private var selectedMaterial: BallMaterial = .rubber

    var body: some View {
        ZStack {
            ARViewContainer(arManager: arManager, selectedMaterial: $selectedMaterial)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                VStack(spacing: 16) {
                    // Add Ball Button
                    Button(action: {
                        arManager.spawnBall(material: selectedMaterial)
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Ball")
                        }
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(selectedMaterial.color)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(radius: 4)
                    }

                    // Material Selection Buttons
                    HStack(spacing: 12) {
                        ForEach(BallMaterial.allCases, id: \.self) { material in
                            Button(action: {
                                selectedMaterial = material
                            }) {
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(material.color)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedMaterial == material ? 3 : 0)
                                        )
                                        .shadow(color: selectedMaterial == material ? material.color.opacity(0.6) : .clear, radius: 6)

                                    Text(material.name)
                                        .font(.caption)
                                        .fontWeight(selectedMaterial == material ? .bold : .regular)
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedMaterial == material ? Color.white.opacity(0.25) : Color.clear)
                                )
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.6))
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - AR View Container
struct ARViewContainer: UIViewRepresentable {
    let arManager: ARSessionManager
    @Binding var selectedMaterial: BallMaterial

    func makeUIView(context: Context) -> ARView {
        let arView = arManager.arView

        // Add pan gesture for dragging balls
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        arView.addGestureRecognizer(panGesture)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.selectedMaterial = selectedMaterial
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(arManager: arManager, selectedMaterial: selectedMaterial)
    }

    class Coordinator: NSObject {
        let arManager: ARSessionManager
        var selectedMaterial: BallMaterial
        var draggedEntity: ModelEntity?
        var lastPanLocation: CGPoint = .zero
        var panStartTime: Date?

        init(arManager: ARSessionManager, selectedMaterial: BallMaterial) {
            self.arManager = arManager
            self.selectedMaterial = selectedMaterial
        }

        @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
            let arView = arManager.arView
            let location = recognizer.location(in: arView)

            switch recognizer.state {
            case .began:
                // Find entity at touch location
                if let entity = arView.entity(at: location) as? ModelEntity,
                   entity.name == "ball" {
                    draggedEntity = entity
                    lastPanLocation = location
                    panStartTime = Date()

                    // Temporarily make kinematic for smooth dragging
                    if var physics = entity.components[PhysicsBodyComponent.self] {
                        physics.mode = .kinematic
                        entity.components[PhysicsBodyComponent.self] = physics
                    }
                }

            case .changed:
                guard let entity = draggedEntity else { return }

                // Move ball based on pan
                let translation = recognizer.translation(in: arView)

                // Convert screen movement to world movement
                let cameraTransform = arView.cameraTransform
                let right = SIMD3<Float>(cameraTransform.matrix.columns.0.x,
                                          cameraTransform.matrix.columns.0.y,
                                          cameraTransform.matrix.columns.0.z)
                let up = SIMD3<Float>(0, 1, 0)

                let movementScale: Float = 0.001
                let worldMovement = right * Float(translation.x) * movementScale +
                                   up * Float(-translation.y) * movementScale

                entity.position += worldMovement
                recognizer.setTranslation(.zero, in: arView)
                lastPanLocation = location

            case .ended, .cancelled:
                guard let entity = draggedEntity else { return }

                // Calculate velocity from gesture
                let velocity = recognizer.velocity(in: arView)

                // Convert screen velocity to world velocity
                let cameraTransform = arView.cameraTransform
                let right = SIMD3<Float>(cameraTransform.matrix.columns.0.x,
                                          cameraTransform.matrix.columns.0.y,
                                          cameraTransform.matrix.columns.0.z)
                let forward = -SIMD3<Float>(cameraTransform.matrix.columns.2.x,
                                            cameraTransform.matrix.columns.2.y,
                                            cameraTransform.matrix.columns.2.z)

                // Make dynamic again and apply impulse
                if var physics = entity.components[PhysicsBodyComponent.self] {
                    physics.mode = .dynamic
                    entity.components[PhysicsBodyComponent.self] = physics

                    // Apply impulse based on swipe velocity
                    let velocityScale: Float = 0.0003
                    let impulse = right * Float(velocity.x) * velocityScale +
                                 forward * Float(-velocity.y) * velocityScale

                    entity.applyLinearImpulse(impulse, relativeTo: nil)
                }

                draggedEntity = nil
                panStartTime = nil

            default:
                break
            }
        }
    }
}

// MARK: - Ball Material Types
enum BallMaterial: CaseIterable {
    case wood
    case plastic
    case rubber
    case metal

    var name: String {
        switch self {
        case .wood: return "Wood"
        case .plastic: return "Plastic"
        case .rubber: return "Rubber"
        case .metal: return "Metal"
        }
    }

    var color: Color {
        switch self {
        case .wood: return Color(red: 0.72, green: 0.53, blue: 0.35)
        case .plastic: return Color.yellow
        case .rubber: return Color.red
        case .metal: return Color.gray
        }
    }

    // Restitution controls bounciness (0 = no bounce, 1 = perfect bounce)
    var restitution: Float {
        switch self {
        case .wood: return 0.3
        case .plastic: return 0.5
        case .rubber: return 0.9
        case .metal: return 0.2
        }
    }

    // Friction affects sliding behavior
    var friction: Float {
        switch self {
        case .wood: return 0.5
        case .plastic: return 0.3
        case .rubber: return 0.8
        case .metal: return 0.4
        }
    }

    // Mass affects momentum and force response
    var mass: Float {
        switch self {
        case .wood: return 0.5
        case .plastic: return 0.3
        case .rubber: return 0.4
        case .metal: return 2.0
        }
    }

    var roughness: Float {
        switch self {
        case .wood: return 0.7
        case .plastic: return 0.3
        case .rubber: return 0.9
        case .metal: return 0.1
        }
    }

    var isMetallic: Bool {
        self == .metal
    }
}

#Preview {
    ContentView()
}
