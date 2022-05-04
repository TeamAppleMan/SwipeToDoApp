//
//  AddCategoryViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/22.
//

import UIKit
protocol AddCategoryViewControllerDelegate{
    func catchAddedCategoryData(catchAddedCategoryList: CategoryList)
}
class AddCategoryViewController: UIViewController {

    @IBOutlet private var horizontalCollectionView: UICollectionView!
    @IBOutlet private var categoryNameTextField: UITextField!
    @IBOutlet private var albumButton: UIButton!

    var delegate: AddCategoryViewControllerDelegate?

    var checkPermission = CheckPermission()

    // 追加するカテゴリ名
    var addedCategoryList: CategoryList = CategoryList(value: [])

    // HACK: テンプレートカテゴリ 要検討案件です〜
    private var templatePhotoArray: [String] = ["programming","cooking","imac","manran","mtg","coffee"]
    private var templateCategoryNameArray: [String] = ["プログラミング","料理","PC作業","運動","打ち合わせ","勉強"]

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
        categoryNameTextField.delegate = self
        horizontalCollectionView.delegate = self
        horizontalCollectionView.dataSource = self
        horizontalCollectionView.decelerationRate = .fast // 動作もっさりなので早く見せる
        horizontalCollectionView.showsHorizontalScrollIndicator = false // 下のインジケータを削除
        // アルバムボタンを押せなくする（テキストフィールドに値が入ってないため）
        albumButton.isEnabled = false
        // 押せないことをアピールするためにalpha値を0.1にしている
        albumButton.alpha = 0.1
        checkPermission.checkAlbum()
        let nib = UINib(nibName: "TemplateCategoryCollectionViewCell", bundle: .main)
        horizontalCollectionView.register(nib, forCellWithReuseIdentifier: "CategoryCollectionID")
        setTestLayout()
    }
    // 0番目のCellからスタートする
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        horizontalCollectionView.scrollToItem(at: IndexPath(row: 4, section: 0), at: .centeredHorizontally, animated: false)
    }

    @IBAction private func tappedAlbumButton(_ sender: Any) {
        // テキストフィールドが空であればアラート出す
        if categoryNameTextField.text == ""{
           let message = "カテゴリ名を入力してください"
           let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
           let ok = UIAlertAction(title: "OK", style: .default,handler: nil)
            alert.addAction(ok)
           // アラートを表示
           present(alert,animated: true,completion: nil)
           return
        }
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        createImagePicker(sourceType: sourceType)
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
        cellWidth = UIScreen.main.bounds.width - 60
        let testLayout = PagingPerCellFlowLayout()
        testLayout.headerReferenceSize = CGSize(width: 30, height: horizontalCollectionView.frame.height)
        testLayout.footerReferenceSize = CGSize(width: 30, height: horizontalCollectionView.frame.height)
        testLayout.scrollDirection = .horizontal
        testLayout.minimumLineSpacing = 16
        testLayout.itemSize = CGSize(width: cellWidth, height: horizontalCollectionView.frame.height)
        horizontalCollectionView.collectionViewLayout = testLayout
    }


    @IBAction func changedTextField(_ sender: Any) {
        if categoryNameTextField.text == "" {
            albumButton.isEnabled = false
            albumButton.alpha = 0.1
        } else {
            albumButton.isEnabled = true
            albumButton.alpha = 1
        }
    }

}

extension AddCategoryViewController: UITextFieldDelegate{
    // テキストを編集するたびに呼ばれるデリゲートメソッド
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // カテゴリ名がテキストフィールドに入力されるとアルバムボタンを押せるようにする
        albumButton.isEnabled = true
        // アルバムボタンを押せるとアピールするためにalpha値をデフォルトの1に戻す
        albumButton.alpha = 1
        return true
    }
    // Returnを押した時にキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
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
        cell.backgroundImageView.image = UIImage(named: templatePhotoArray[indexPath.row])
        cell.backgroundImageView.image = cell.darkenPictureCollectionViewCell(image: UIImage(named: templatePhotoArray[indexPath.row])!, level: 0.5)
        return cell
    }

    // セル同士の間隔を決めるデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
    // セルのサイズを決めるデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellWidth = viewWidth - 120
        cellHeight = viewHeight - 450
        cellOffset = viewWidth - cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }

    // 余白の調整
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,left: cellOffset / 2,bottom: 0,right: cellOffset / 2)
    }

    // セルをタップしたら呼ばれるメソッド
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategoryName: String = templateCategoryNameArray[indexPath.row]
        let selectedCategoryPhoto: UIImage = UIImage(named: (templatePhotoArray[indexPath.row]))!
        let alertController = UIAlertController(title: "カテゴリ追加", message: "\(selectedCategoryName)をカテゴリ一覧に追加しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            // カテゴリ一覧画面に画像をカテゴリ名前を渡す
            self.addedCategoryList.name = selectedCategoryName
            self.addedCategoryList.photo = selectedCategoryPhoto.pngData()
            self.delegate?.catchAddedCategoryData(catchAddedCategoryList: self.addedCategoryList)
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default){ (cancel) in
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
            let categoryName: String = categoryNameTextField.text ?? ""
            let categoryPhoto: UIImage = pickerImage
            addedCategoryList.name = categoryName
            addedCategoryList.photo = categoryPhoto.pngData()
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
