# FirebaseWrapperSPM

<div id="top"></div>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/github_username/repo_name">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">FirebaseWrapperSPM</h3>

  <p align="center">
    This SPM aims to save boiler plate code from Firebase "Data" SDKs (Firestore, Database and Storage). Using the SPM you'll be able to :
       Transform your saved data to Codable (FirebaseCodable), Upload files from XCAssets, Bundle and FileManage, Downlad and pull file from Caches/Download folder, Write a cleaner and shorter code.
    <br />
    <a href="https://github.com/github_username/repo_name"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/github_username/repo_name">View Demo</a>
    ·
    <a href="https://github.com/github_username/repo_name/issues">Report Bug</a>
    ·
    <a href="https://github.com/github_username/repo_name/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
### Built With

* [Swift](https://developer.apple.com/swift/)
* [SPM](https://swift.org/package-manager/)
* [Firebase SPM](https://firebase.google.com/docs/ios/swift-package-manager)


<p align="right">(<a href="#top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites
  <ol>
     <li><a>Xcode</a></li>
     <li><a>Swift 5.0 <.. </a></li>
     <li><a>Project Deployment target 13 <..</a></li>
  </ol>

### Installation

1. Get a GoogleService-info.plist from Firebase(https://firebase.google.com/)
2. Install it at the root of your project
3. Open File > Add Packages...
4. Insert in the search bar :    
  ```sh
   https://github.com/boulomiel/FirebaseWrapperSPM.git
   ```
6. Select the the update version 1.0.1 or higher or the "main" branch. 
7. Wait until installation is finished

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

```sh
import Foundation
import FirebaseWrapperSPM


struct User : FirebaseCodable{
    var age : Int
    var name : String
    var city : String
    var food : String
    var gender : String
    var date : String
    var pets : [Pet]?
    //var lastUpdated : String?
}
```

```sh
import Foundation
import FirebaseWrapperSPM

struct Pet : FirebaseCodable{
    var name : String
}
```


```sh
import Foundation
import FirebaseWrapperSPM


struct User : FirebaseCodable{
    var age : Int
    var name : String
    var city : String
    var food : String
    var gender : String
    var date : String
    var pets : [Pet]?
    //var lastUpdated : String?
}
```


```sh
import Foundation
import UIKit
import FirebaseWrapperSPM

class ViewController : UIViewController{
    let db = DBWrapper()
    var dbRef : DatabaseReference!
    let storageWrapper = StorageWrapper()
    let firestoreWrapper = FiretoreWrapper()

    let user  = User(age: 29, name: "Jhon ", city: "London", food: "Couscous", gender: "mal", date: "02/03/1993", pets: [Pet(name: "Bounton"), Pet(name: "Tagada"), Pet(name: "Telma")])
    
    override func viewDidLoad() {
        dbRef = db.getRef().child("Users/friends/")
    }
    
    
 // Mark : -  DBWrapper integ 
    
        func dbWrapperTest(){

//        db.observe(for: dbRef, eventType: .childAdded, valueType: User.self) {[weak self] result in
//            switch result{
//            case .failure(let error):
//                print(error)
//            case .success(let decodable):
//                print("OBSERVE", decodable.self)
//                self?.dataSource.append(decodable)
//                DispatchQueue.main.async {
//                    self?.tableView?.reloadData()
//                }
//            }
//        }
        
        db.getData(for: dbRef, decode: User.self) {[weak self] result  in
            switch result{
            case .failure(let error):
                print(error)
            case .success(let decodable):
                print("getData", decodable.self)
                self?.dataSource = decodable
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                }
            }
        }
        

        db.getData(for: dbRef){result in
            switch result{
            case .failure(let error):
                print(error)
            case .success(let data):
                print("GETDATA", data)

            }
        }



        db.getData(for: "name", in: refJon) { result in
            switch result {
            case .failure(let error):
            print(error)
            case .success(let data):
            print("GETDATA FOR VALUE", data)
            }
        }
        
        db.getDataOnceForEvent(event: .childAdded) { result in
            switch result{
            case .failure(let error):
            print(error)
            case .success(let data):
            print("GET DATA ONCE FOR EVENT CHILD ADDED",data)
            }
        }
        
        db.getDataOnceForEvent(for: dbRef, event: .childAdded,decode: User.self) { result in
            switch result{
            case .failure(let error):
            print(error)
            case .success(let data):
            print("GET DATA ONCE FOR EVENT CHILD CHANGED - decodable ",data)
            }
        }
        
        db.updateChildrenValues(in: refJon, paths: "name", "food", values: "ruben","merguez")
        
        user.name = "Yael"
        writeToDb()
        
    }
    
    
   func writeToDb(){
        let date =  Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        let strDate = dateFormatter.string(from: date)

        db.write(at: "Users/friends/\(user.name)", value: user.toDict())
    }
    
    
   // Mark - : FirestoreWrapper integ
   
       func addDocument(){
        firestoreWrapper.addData(collectionName: "Users", data: user) { result in
            switch result{
            case .success(let documentId):
                print("ADD DOCUMENT" , documentId)
            case .failure(let error):
                print("ADD DOCUMENT", error.localizedDescription)
            }
        }
    }
    
    func addDocumentWithId(){
        firestoreWrapper.addDocumentWitId(collectionName: "Users", data: user, documentId: "Weirdo")
    }
    
    
    func updateData(){
        firestoreWrapper.updateData(for: "Weirdo", in: "Users", data: ["age":120]) { result in
            switch result{
            case .success(let documentId):
                print("UPDATE DATA" , "\(documentId) successfully updated")
            case .failure(let error):
                print("UPDATE DATA", error.localizedDescription)
            }
        }
    }
    
    func retrieveDataOnce(){
        firestoreWrapper.retrieveOnce(from: "Users", where: "Weirdo", decode: User.self) { result in
            switch result{
            case .success(let value):
                print("RETRIEVE DATA ONCE" , value)
            case .failure(let error):
                print("RETRIEVE DATA ONCE", error.localizedDescription)
            }
        }
    }
    
    func retrieveMultiple(){
        let query = firestoreWrapper.getQueryEqualTo(in: "Users", for: "city", value: "London")
        firestoreWrapper.retrieveMultipleOnce(from: query, decode: User.self) { [weak self]result in
            switch result{
            case .success(let values):
                print("RETRIEVE MULTIPLE ONCE", values)
                self?.dataSource = values
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                }
            case .failure(let error):
                print("RETRIEVE MULTIPLE ONCE ", error.localizedDescription)
            }
        }
    }
    
    func retrieveAll(){
        firestoreWrapper.retrieveAllOnce(from: "Users", decode: User.self) { result in
            switch result{
            case .success(let values):
                values.forEach { user in
                    print("PETS RETRIEVED FROM ALL" , user?.pets ?? "NO PETS" )
                }
            case .failure(let error):
                print("RETRIEVE MULTIPLE", error.localizedDescription)
            }
        }
    }
    
    
    
    // Mark - StorageWrapper integ :
    
    func uploadFileLocal(){
        let storageRef = storageWrapper.getReference(for: "images/pikachu.jpeg", from: false)
        if let ref = storageRef,
           let localURL = URL.localURLForXCAsset(name: "pikachu", withExtension: "jpg") {
            storageWrapper.uploadFile(from: localURL, in: ref) { result in
                switch result{
                case .success(let successUrl):
                    print("upload file local", "SUCCESS -  \(successUrl?.absoluteString ?? "")")
                case .failure(let error):
                    print("upload file local", "FAILURE -  \(error)")
                }
            }
        }
        

    }
    
    
    func uploadFileFromData(){
        if let image =  UIImage(named: "pikachu"),
           let dataImage =  image.pngData(),
           let storageRef = storageWrapper.getReference(for: "images/pikachu2.png", from: false){
            storageWrapper.uploadFile(from: dataImage, in: storageRef){result in
                switch result{
                case .success(let successUrl):
                    print("upload file data", "SUCCESS -  \(successUrl?.absoluteString ?? "")")
                case .failure(let error):
                    print("upload file data", "FAILURE -  \(error)")
                }
            }
        }
        storageWrapper.addUploadingObserver(taskStatus: .success)
            
    }
    
        func downloadFile(fromPath : String){
        if let ref =  storageWrapper.getReference(for: fromPath, from: false){
            storageWrapper.getDownloadURL(from: ref) {[weak self] resul in
                switch resul{
                case .success(let url):
                    print("Download file", "URL : \(url)")
                    self?.downloadFileWithUrl(urlString: url.absoluteString)
                case .failure(let error):
                    print("Download file", error)

                }
            }
        }
        
    }
    
    
```

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- ROADMAP -->
<!-- ## Roadmap

- [] Feature 1
- [] Feature 2
- [] Feature 3
    - [] Nested Feature

See the [open issues](https://github.com/github_username/repo_name/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#top">back to top</a>)</p>

 -->

<!-- CONTRIBUTING -->
<!-- ## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>
 -->


<!-- LICENSE -->
<!-- ## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p> -->



<!-- CONTACT -->
<!-- ## Contact

Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - email@email_client.com

Project Link: [https://github.com/github_username/repo_name](https://github.com/github_username/repo_name)

<p align="right">(<a href="#top">back to top</a>)</p> -->



<!-- ACKNOWLEDGMENTS -->
<!-- ## Acknowledgments

* []()
* []()
* []()

<p align="right">(<a href="#top">back to top</a>)</p>
 -->


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
<!-- [contributors-shield]: https://img.shields.io/github/contributors/github_username/repo_name.svg?style=for-the-badge
[contributors-url]: https://github.com/github_username/repo_name/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/github_username/repo_name.svg?style=for-the-badge
[forks-url]: https://github.com/github_username/repo_name/network/members
[stars-shield]: https://img.shields.io/github/stars/github_username/repo_name.svg?style=for-the-badge
[stars-url]: https://github.com/github_username/repo_name/stargazers
[issues-shield]: https://img.shields.io/github/issues/github_username/repo_name.svg?style=for-the-badge
[issues-url]: https://github.com/github_username/repo_name/issues
[license-shield]: https://img.shields.io/github/license/github_username/repo_name.svg?style=for-the-badge
[license-url]: https://github.com/github_username/repo_name/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png -->


Here is an integration example :
https://github.com/boulomiel/sdkwrappertest
