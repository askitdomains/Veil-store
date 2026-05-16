// Replace the old import:
// import FirebaseFirestoreSwift

// With the new import:
import FirebaseFirestore

class AppStoreService: ObservableObject {
    @Published var allApps: [AppEntry] = []
    @Published var featuredApps: [AppEntry] = []
    @Published var categories: [String: [AppEntry]] = [:]
    private let db = Firestore.firestore()

    func fetchApps() async {
        do {
            let snapshot = try await db.collection("apps")
                .whereField("isActive", isEqualTo: true)
                .getDocuments()
            let apps = snapshot.documents.compactMap { try? $0.data(as: AppEntry.self) }
            await MainActor.run {
                self.allApps = apps
                self.featuredApps = apps.filter { $0.featured }
                self.categories = Dictionary(grouping: apps, by: { $0.category })
            }
        } catch {
            print("Error fetching apps: \(error)")
        }
    }

    func addApp(_ app: AppEntry) async throws {
        let _ = try await db.collection("apps").addDocument(from: app)
    }
}
