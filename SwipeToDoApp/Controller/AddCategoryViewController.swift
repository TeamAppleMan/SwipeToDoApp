//
//  AddCategoryViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/22.
//

import UIKit
import RealmSwift

protocol AddCategoryViewControllerDelegate{
    func catchAddedCategoryData(catchAddedCategoryList: Category)
}

class AddCategoryViewController: UIViewController {

    @IBOutlet private weak var horizontalCollectionView: UICollectionView!

    var delegate: AddCategoryViewControllerDelegate?
    var checkPermission = CheckPermission()
    var createdCategoryName: String = ""
    var categoryList: Results<Category>!

    // 追加するカテゴリ名
    var addedCategoryList: Category = Category(value: [])

    // テンプレートカテゴリ
    private var templatePhotoArray: [String] = ["料理","読書","買い物","勉強","子育て","副業"]
    private var templateCategoryNameArray: [String] = ["料理","読書","買い物","勉強","子育て","副業"]

    // CollectionView関連の変数
    private var viewWidth: CGFloat!
    private var viewHeight: CGFloat!
    private var cellWidth: CGFloat!
    private var cellHeight: CGFloat!
    private var cellOffset: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewWidth = view.frame.width
        viewHeight = view.frame.height
        cellWidth = viewWidth/1.5
        cellHeight = viewHeight/2.5
        cellOffset = viewWidth-cellWidth
        horizontalCollectionView.delegate = self
        horizontalCollectionView.dataSource = self
        horizontalCollectionView.decelerationRate = .fast // 動作もっさりなので早く見せる
        horizontalCollectionView.showsHorizontalScrollIndicator = false // 下のインジケータを削除
        checkPermission.checkAlbum()
        let nib = UINib(nibName: "TemplateCategoryCollectionViewCell", bundle: .main)
        horizontalCollectionView.register(nib, forCellWithReuseIdentifier: "CategoryCollectionID")
        setTestLayout()
    }

    // 4番目のCellからスタートする
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        horizontalCollectionView.scrollToItem(at: IndexPath(row: 3, section: 0), at: .centeredHorizontally, animated: false)
    }

    // アルバムを開くメソッド
    private func createImagePicker(sourceType: UIImagePickerController.SourceType){
        let albumImagePicker = UIImagePickerController()
        albumImagePicker.sourceType = sourceType
        albumImagePicker.delegate = self
        albumImagePicker.allowsEditing = true
        present(albumImagePicker,animated: true,completion: nil)
    }

    // 余白をタッチしたらキーボードを閉じる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    private func setTestLayout(){
        let testLayout = PagingPerCellFlowLayout()
        testLayout.headerReferenceSize = CGSize(width: 30, height: horizontalCollectionView.frame.height)
        testLayout.footerReferenceSize = CGSize(width: 30, height: horizontalCollectionView.frame.height)
        testLayout.scrollDirection = .horizontal
        testLayout.minimumLineSpacing = 16
        testLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        horizontalCollectionView.collectionViewLayout = testLayout
    }

    @IBAction private func tappedAlbumButton(_ sender: Any) {
        // アラートを出す
        categoryCreateAlert()
    }

    // HACK: コード汚すぎる。。
    private func categoryCreateAlert(){
        let alertController = UIAlertController(title: "オリジナルカテゴリの作成", message: "カテゴリ名を入力してください", preferredStyle: .alert)
        // OKが押されたら写真モードに遷移
        let okAction = UIAlertAction(title: "追加", style: .default) { (ok) in
            if let inputCategoryName = alertController.textFields?[0].text {
                // 入力されたカテゴリ名が空の場合
                if inputCategoryName == "" {
                    let emptyCategoryNameAlertController = UIAlertController(title: "カテゴリ名が空です", message: "カテゴリ名を入力してください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "戻る", style: .default) { (action) in
                        self.navigationController?.popViewController(animated: true)
                    }
                    emptyCategoryNameAlertController.addAction(ok)
                    self.present(emptyCategoryNameAlertController, animated: true, completion: nil)
                    return
                }
                // strがすでにRealmにあるカテゴリ名とかぶっていたら、カテゴリ名が被っていますアラートを出す
                let categoryDuplicationAlertController = UIAlertController(title: "カテゴリ名が重複しています", message: "別のカテゴリ名を入力してください", preferredStyle: .alert)
                let realm = try! Realm()
                let categoryNameFilters = realm.objects(Category.self)
                // textFieldに入力された前後の空白を消す
                let trimmedText = inputCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                for filter in categoryNameFilters {
                    // 入力したカテゴリ名とRealmに入っているCategoryListのnameと被っていた時
                    if filter.name == trimmedText {
                        // カテゴリ重複アラートの表示
                        let ok = UIAlertAction(title: "戻る", style: .default) { (action) in
                            self.navigationController?.popViewController(animated: true)
                        }
                        categoryDuplicationAlertController.addAction(ok)
                        self.present(categoryDuplicationAlertController, animated: true, completion: nil)
                        self.present(alertController, animated: true,completion: nil)
                        return
                    }
                }
                self.createdCategoryName = trimmedText
            }
            // アラートを出す
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            let cameraAction = UIAlertAction(title: "写真を撮る", style: .default) { (ok) in
                // カメラを起動
                let sourceType: UIImagePickerController.SourceType = .camera
                self.createImagePicker(sourceType: sourceType)
            }
            let albumAction = UIAlertAction(title: "写真を選択", style: .default) { (cancel) in
                //　アルバムを起動
                let sourceType: UIImagePickerController.SourceType = .photoLibrary
                self.createImagePicker(sourceType: sourceType)
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (cancel) in
                alertController.dismiss(animated: true, completion: nil)
            }
            // UIAlertControllerにActionを追加
            let photoImage = UIImage(systemName: "photo")
            let cameraImage = UIImage(systemName: "camera")
            alertController.addAction(albumAction)
            alertController.addAction(cameraAction)
            alertController.addAction(cancelAction)
            albumAction.setValue(photoImage, forKey: "image")
            cameraAction.setValue(cameraImage, forKey: "image")
            // Alertを表示
            self.present(alertController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (cancel) in
            alertController.dismiss(animated: true, completion: nil)
        }
        // アラートにテキストフィールドを追記
        alertController.addTextField(configurationHandler: {(textField:UITextField!) -> Void in
              // ここでテキストフィールドのカスタマイズができる
              textField.placeholder = ""
              textField.keyboardType = .default

        })
        // OKとCANCELを表示追加し、アラートを表示
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}

extension AddCategoryViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templatePhotoArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionID", for: indexPath) as! TemplateCategoryCollectionViewCell
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 12 // セルを角丸にする
        cell.layer.shadowOpacity = 0.4// セルの影の濃さを調整する
        cell.layer.shadowRadius = 12 // セルの影の角丸
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 10, height: 10) // 影の方向
        cell.layer.masksToBounds = false
        cell.categoryNameLabel.text = templateCategoryNameArray[indexPath.row]
        print("cell.categoryNameLabel.text:",cell.categoryNameLabel.text!)
        cell.backgroundImageView.image = UIImage(named: templatePhotoArray[indexPath.row])
        cell.backgroundImageView.image = cell.darkenPictureCollectionViewCell(image: UIImage(named: templatePhotoArray[indexPath.row])!, level: 0.5)
        return cell
    }

    // セル同士の間隔を決めるデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }

    // 余白の調整
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,left: cellOffset / 2,bottom: 0,right: cellOffset / 2)
    }

    // セルをタップしたら呼ばれるメソッド
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategoryName: String = templateCategoryNameArray[indexPath.row]
        let selectedCategoryPhoto: UIImage = UIImage(named: (templatePhotoArray[indexPath.row]))!
        // カテゴリが被っていた時にアラートを出す
        let categoryDuplicationAlertController = UIAlertController(title: "カテゴリが重複しています", message: "別のカテゴリ名を選んでください", preferredStyle: .alert)
        let realm = try! Realm()
        let categoryNameFilters = realm.objects(Category.self)
        for filter in categoryNameFilters {
            if filter.name == selectedCategoryName {
                // カテゴリ重複アラートの表示
                let ok = UIAlertAction(title: "戻る", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                categoryDuplicationAlertController.addAction(ok)
                present(categoryDuplicationAlertController, animated: true, completion: nil)
                return
            }
        }

        // カテゴリが被っていない時の処理
        let alertController = UIAlertController(title: "カテゴリ追加", message: "\(selectedCategoryName)をカテゴリ一覧に追加しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "追加", style: .default) { (ok) in
            // カテゴリ一覧画面に画像をカテゴリ名前を渡す
            self.addedCategoryList.name = selectedCategoryName
            self.addedCategoryList.image = selectedCategoryPhoto.pngData()!
            self.delegate?.catchAddedCategoryData(catchAddedCategoryList: self.addedCategoryList)
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default){ (cancel) in
            alertController.dismiss(animated: true, completion: nil)
        }
        // OKとCANCELを表示追加し、アラートを表示
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension AddCategoryViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    // アルバムのキャンセルボタンがタップされた時に呼ばれるデリゲートメソッド
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }

    // アルバムで画像を選択した時に呼ばれるデリゲートメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickerImage = info[.editedImage] as? UIImage{
            let categoryName: String = createdCategoryName
            let categoryPhoto: UIImage = pickerImage
            addedCategoryList.name = categoryName
            addedCategoryList.image = categoryPhoto.pngData()!
            // 選択した画像とカテゴリ名をCategoryListViewControllerに渡す
            delegate?.catchAddedCategoryData(catchAddedCategoryList: addedCategoryList)
            picker.dismiss(animated: true,completion: nil)
            navigationController?.popViewController(animated: true)
        }
    }
}

/// カルーセルスワイプ時にcellが真ん中に来るように
class PagingPerCellFlowLayout: UICollectionViewFlowLayout {

   var cellWidth: CGFloat = UIScreen.main.bounds.width - 60
   let windowWidth: CGFloat = UIScreen.main.bounds.width

   override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
       if let collectionViewBounds = self.collectionView?.bounds {
           let halfWidthOfVC = collectionViewBounds.size.width * 0.5
           let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidthOfVC
           if let attributesForVisibleCells = self.layoutAttributesForElements(in: collectionViewBounds) {
               var candidateAttribute: UICollectionViewLayoutAttributes?
               for attributes in attributesForVisibleCells {
                   let candAttr: UICollectionViewLayoutAttributes? = candidateAttribute
                   if candAttr != nil {
                       let a = attributes.center.x - proposedContentOffsetCenterX
                       let b = candAttr!.center.x - proposedContentOffsetCenterX
                       if abs(a) < abs(b) {
                           candidateAttribute = attributes
                       }
                   } else {
                       candidateAttribute = attributes
                       continue
                   }
               }
               if candidateAttribute != nil {
                   return CGPoint(x: candidateAttribute!.center.x - halfWidthOfVC, y: proposedContentOffset.y)
               }
           }
       }
       return CGPoint.zero
   }
}
