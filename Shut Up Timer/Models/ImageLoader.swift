import SwiftUI;

class ImageLoader {
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private static func getImageURL(_ name: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent("image_\(name).jpg")
    }
    
    static func loadImage(name: String) -> UIImage? {
        let url = getImageURL(name)
        return UIImage(contentsOfFile: url.path)
    }
    
    static func saveImage(name: String, image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return false }
        let url = getImageURL(name)
        
        do {
            try data.write(to: url)
            return true
        } catch {
            print("Failed to save image:", error)
            return false
        }
    }
    
}
