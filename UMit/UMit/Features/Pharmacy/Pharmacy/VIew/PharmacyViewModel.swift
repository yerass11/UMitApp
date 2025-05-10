import FirebaseFirestore

final class PharmacyViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []

    private let db = Firestore.firestore()

    func placeOrder(medicine: Medicine, userId: String, quantity: Int, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "medicineId": medicine.id ?? "",
            "medicineName": medicine.name,
            "imageURL": medicine.imageURL,
            "points": medicine.points,
            "quantity": quantity,
            "userId": userId,
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("orders").addDocument(data: data, completion: completion)
    }
    
    func fetchMedicines() {
        print("🔍 Starting to fetch medicines...")
        
        db.collection("medicines").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("❌ Firestore error:", error.localizedDescription)
                return
            }

            print("📄 Documents count:", snapshot?.documents.count ?? 0)
            
            guard let documents = snapshot?.documents else {
                print("⚠️ No documents found in 'medicines' collection")
                print("🔄 Creating sample medicines...")
                self?.createSampleMedicines()
                return
            }

            print("📝 Processing \(documents.count) documents...")
            
            let meds = documents.compactMap { doc -> Medicine? in
                do {
                    var medicine = try doc.data(as: Medicine.self)
                    print("✅ Successfully decoded medicine: \(medicine.name)")
                    
                    if medicine.category == nil {
                        medicine.category = .other
                        print("ℹ️ Set default category for \(medicine.name)")
                    }
                    if medicine.isPrescriptionRequired == nil {
                        medicine.isPrescriptionRequired = false
                        print("ℹ️ Set default prescription status for \(medicine.name)")
                    }
                    if medicine.isAvailable == nil {
                        medicine.isAvailable = true
                        print("ℹ️ Set default availability for \(medicine.name)")
                    }
                    return medicine
                } catch {
                    print("❌ Error decoding medicine from document \(doc.documentID):", error)
                    return nil
                }
            }

            print("📦 Successfully processed \(meds.count) medicines")
            DispatchQueue.main.async {
                self?.medicines = meds
                print("✅ Updated medicines array with \(meds.count) items")
            }
        }
    }
    
    private func createSampleMedicines() {
        print("🎨 Creating sample medicines...")
        
        let sampleMedicines: [Medicine] = [
            Medicine(
                name: "Paracetamol 500mg",
                description: "Pain reliever and fever reducer. Used to treat many conditions such as headache, muscle aches, arthritis, backache, toothaches, colds, and fevers.",
                points: 15,
                imageURL: "https://example.com/paracetamol.jpg",
                category: .painRelief,
                isPrescriptionRequired: false,
                isAvailable: true
            ),
            Medicine(
                name: "Amoxicillin 250mg",
                description: "Antibiotic used to treat a wide variety of bacterial infections. This medication is a penicillin-type antibiotic.",
                points: 45,
                imageURL: "https://example.com/amoxicillin.jpg",
                category: .antibiotics,
                isPrescriptionRequired: true,
                isAvailable: true
            ),
            Medicine(
                name: "Vitamin D3 1000IU",
                description: "Supports bone health, immune function, and muscle strength. Essential for calcium absorption.",
                points: 25,
                imageURL: "https://example.com/vitamind.jpg",
                category: .vitamins,
                isPrescriptionRequired: false,
                isAvailable: true
            ),
            Medicine(
                name: "First Aid Kit",
                description: "Complete first aid kit containing bandages, antiseptic wipes, pain relievers, and other emergency supplies.",
                points: 35,
                imageURL: "https://example.com/firstaid.jpg",
                category: .firstAid,
                isPrescriptionRequired: false,
                isAvailable: true
            ),
            Medicine(
                name: "Moisturizing Cream",
                description: "Hydrating cream for dry skin. Contains natural ingredients to soothe and protect skin.",
                points: 20,
                imageURL: "https://example.com/moisturizer.jpg",
                category: .skincare,
                isPrescriptionRequired: false,
                isAvailable: true
            )
        ]
        
        print("📝 Preparing to write \(sampleMedicines.count) medicines to Firestore...")
        
        let batch = db.batch()
        
        for medicine in sampleMedicines {
            let docRef = db.collection("medicines").document()
            do {
                try batch.setData(from: medicine, forDocument: docRef)
                print("✅ Added \(medicine.name) to batch")
            } catch {
                print("❌ Error adding \(medicine.name) to batch:", error)
            }
        }
        
        print("🔄 Committing batch to Firestore...")
        
        batch.commit { error in
            if let error = error {
                print("❌ Error creating sample medicines:", error.localizedDescription)
            } else {
                print("✅ Sample medicines created successfully")
                print("🔄 Fetching newly created medicines...")
                self.fetchMedicines()
            }
        }
    }
}
