//
//  MotivationViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/25.
//

import Foundation
import RealmSwift
import UIKit
import Charts

class MotivationViewController: UIViewController {

    private var categoryLists: Results<Category>!
    private var tasks: Results<Task>!
    private var presentDate: Date!
    private var notAchieveData: [Data] = []
    private var todayDate: Date!

    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var centerView: UIView!
    @IBOutlet private weak var buttomView: UIView!

    @IBOutlet private weak var beforeMonthButton: UIBarButtonItem!
    @IBOutlet private weak var afterMonthButton: UIBarButtonItem!
    @IBOutlet private weak var taskRangeSegmentedControl: UISegmentedControl!

    // 赤・青・緑のトップバーのLabel
    @IBOutlet private weak var taskCountTopBarLabel: UILabel!
    @IBOutlet private weak var taskRatioTopBarLabel: UILabel!
    @IBOutlet private weak var categoryRatioTopBarLabel: UILabel!

    @IBOutlet private weak var taskCountSubBarLabel: UILabel!
    @IBOutlet private weak var taskRatioSubBarLabel: UILabel!
    @IBOutlet private weak var categoryRatioSubBarLabel: UILabel!

    @IBOutlet private weak var endTaskLabel: UILabel!
    @IBOutlet private weak var inputTaskLabel: UILabel!
    @IBOutlet private weak var endTaskLabel2: UILabel!
    @IBOutlet private weak var notEndTaskLabel: UILabel!
    @IBOutlet private weak var endTaskNumberLabel1: UILabel!
    @IBOutlet private weak var planTaskNumberLabel: UILabel!
    @IBOutlet private weak var endTaskNumberLabel2: UILabel!
    @IBOutlet private weak var noEndTaskNumberLabel: UILabel!

    @IBOutlet private weak var lineChartDescriptionTopLabel2: UILabel!
    @IBOutlet private weak var lineChartNoDataLabel: UILabel!
    @IBOutlet private weak var lineChartDescriptionButtomLabel2: UILabel!

    @IBOutlet private weak var taskCountOfMonthLineChartView: LineChartView!
    @IBOutlet private weak var taskRatioOfMonthPieChartView: PieChartView!
    @IBOutlet private weak var categoryRatioOfMonthPieChartView: PieChartView!
    @IBOutlet private weak var taskCountOfAllLineChartView: LineChartView!
    @IBOutlet private weak var taskRatioOfAllPieChartView: PieChartView!
    @IBOutlet weak var categoryRatioOfAllPieChartView: PieChartView!

    private var taskCountOfMonthLineDataSet: LineChartDataSet!
    private var taskRatioOfMonthPieDataSet: PieChartDataSet!
    private var categoryRatioOfMonthPieDataSet: PieChartDataSet!
    private var taskCountOfAllLineDataSet: LineChartDataSet!
    private var taskRatioOfMAllPieDataSet: PieChartDataSet!
    private var categoryRatioOfAllPieDataSet: PieChartDataSet!

    private var taskCountOfMonthChartData: [Double] = []
    private var taskRatioOfMonthPieData: [PieChartDataEntry] = []
    private var categoryRatioOfMonthPieData: [PieChartDataEntry] = []
    private var taskCountOfAllChartData: [Double] = []
    private var taskRatioOfAllPieData: [PieChartDataEntry] = []
    private var categoryRatioOfAllPieData: [PieChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        topView.layer.cornerRadius = 12
        topView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowOpacity = 0.4
        topView.layer.shadowRadius = 3

        centerView.layer.cornerRadius = 12
        centerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        centerView.layer.shadowColor = UIColor.black.cgColor
        centerView.layer.shadowOpacity = 0.4
        centerView.layer.shadowRadius = 3
        buttomView.layer.cornerRadius = 12
        buttomView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        buttomView.layer.shadowColor = UIColor.black.cgColor
        buttomView.layer.shadowOpacity = 0.4
        buttomView.layer.shadowRadius = 3

        // 赤・青・緑部分を角丸にする
        taskCountTopBarLabel.layer.cornerRadius = 12
        taskCountTopBarLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        taskCountTopBarLabel.clipsToBounds = true

        taskRatioTopBarLabel.layer.cornerRadius = 12
        taskRatioTopBarLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        taskRatioTopBarLabel.clipsToBounds = true

        categoryRatioTopBarLabel.layer.cornerRadius = 12
        categoryRatioTopBarLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        categoryRatioTopBarLabel.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .black
        let realm = try! Realm()
        tasks = realm.objects(Task.self)
        categoryLists = realm.objects(Category.self)

        // 今日を取得して、データに格納
        let calPosition = Calendar.current
        let todayComppnent = calPosition.dateComponents(
            [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,
             Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second],
             from: Date())
        todayDate = Date.init(year: todayComppnent.year, month: todayComppnent.month, day: todayComppnent.day! + 1, hour: 0, minute: 0, second: 0 )
        presentDate = Date.init(year: todayComppnent.year, month: todayComppnent.month, day: 2, hour: 0, minute: 0, second: 0 )
        self.navigationItem.title = "\(presentDate.year)年\(presentDate.month)月"

        // 他画面でデータ変更後にUI3へ遷移することも考えてあえてViewDidLoadではなくViewWillAppearで毎回再計算
        switch taskRangeSegmentedControl.selectedSegmentIndex {
        case 0:
            presentMonthOrAll(isMonth: true)
        case 1:
            presentMonthOrAll(isMonth: false)
        default:
            print("segmentedControlerでエラー")
        }
    }

    @IBAction private func didTapFrontMonthButton(_ sender: Any) {
        presentDate = presentDate.added(year: 0, month: -1, day: 0, hour: 0, minute: 0, second: 0)
        self.navigationItem.title = "\(presentDate.year)年\(presentDate.month)月"
        // 「前の月」Buttonを押した際に、月間Segmentが選択されている場合のみ再計算
        if taskRangeSegmentedControl.selectedSegmentIndex == 0 {
            presentMonthOrAll(isMonth: true)
        }
    }

    @IBAction private func didTapNextMonthButton(_ sender: Any) {
        presentDate = presentDate.added(year: 0, month: 1, day: 0, hour: 0, minute: 0, second: 0)
        self.navigationItem.title = "\(presentDate.year)年\(presentDate.month)月"
        // 「次の月」Buttonを押した際に、月間Segmentが選択されている場合のみ再計算
        if taskRangeSegmentedControl.selectedSegmentIndex == 0 {
            presentMonthOrAll(isMonth: true)
        }
    }

    @IBAction func didChangedSegmentedControl(_ sender: UISegmentedControl) {

        lineChartNoDataLabel.text = ""
        lineChartDescriptionButtomLabel2.isHidden = false
        lineChartDescriptionTopLabel2.isHidden = false
        endTaskLabel.isHidden = false
        endTaskNumberLabel1.isHidden = false

        switch sender.selectedSegmentIndex {
        case 0:
            presentMonthOrAll(isMonth: true)
        case 1:
            presentMonthOrAll(isMonth: false)
        default:
            print("segmentedControlerでエラー")
        }

    }

    private func calculateMonth() {
        var toMonthTasks:[Task] = []
        taskCountOfMonthChartData = []
        taskRatioOfMonthPieData = []
        categoryRatioOfMonthPieData = []

        // トップの折れ線グラフの計算
        // 当月のTaskかどうかをfilterする
        toMonthTasks = tasks.filter {
            presentDate < $0.date && $0.date < presentDate.added(year: 0, month: 1, day: 0, hour: 0, minute: 0, second: 0)
        }
        for i in 0..<presentDate.getMonthLastDay(MonthLastDate: presentDate) {
            var countArray: [Task] = []

            countArray = toMonthTasks.filter{
                $0.date == presentDate.added(year: 0, month: 0, day: i, hour: 0, minute: 0, second: 0) && $0.isDone == true
            }
            taskCountOfMonthChartData.append(Double(countArray.count))
        }
        createTaskCountOfMonthLineChart(data: taskCountOfMonthChartData)

        //　達成率（円グラフ）計算
        let achieveCount = taskCountOfMonthChartData.reduce(0, +)
        if toMonthTasks.count != 0 {
            let achieveRatio = ( achieveCount / Double(toMonthTasks.count) ) * 100
            taskRatioOfMonthPieData = [
                    PieChartDataEntry(value: Double(achieveRatio), label: "達成"),
                    PieChartDataEntry(value: Double(100 - achieveRatio), label: "未達成")
                ]
            createTaskRatioOfMonthPieChart(dataEntries: taskRatioOfMonthPieData)
        } else {
            // "データがありません"と表示させるために意図的に空にする
            taskRatioOfMonthPieData = []
            createTaskRatioOfMonthPieChart(dataEntries: taskRatioOfMonthPieData)
        }

        //　カテゴリ率（円グラフ）計算
        struct CategoryWithCount {
            var name: String = ""
            var count: Double = 0
        }
        var categoryWithCounts: [CategoryWithCount] = []
        var allCounZeroJadge = 0
        if let categories = categoryLists {
            for category in categories {
                let fileterTasks = toMonthTasks.filter {
                    $0.category == category && $0.isDone == true
                }
                categoryWithCounts.append(CategoryWithCount.init(name: category.name, count: Double(fileterTasks.count)))
                allCounZeroJadge += fileterTasks.count
            }
        }

        // 達成数が大きい順に並べ替える
        categoryWithCounts = categoryWithCounts.sorted(by: {$1.count < $0.count})

        // nilに分類される未カテゴリをappend
        let fileterTasks = toMonthTasks.filter {
            $0.category == nil && $0.isDone == true
        }
        if fileterTasks.count != 0 {
            categoryWithCounts.append(CategoryWithCount.init(name: "未カテゴリ", count: Double(fileterTasks.count)))
            allCounZeroJadge += fileterTasks.count
        }
        // もし全部のデータが0ではなければ画面出力
        if allCounZeroJadge != 0 {
            for categoryWithCount in categoryWithCounts {
                categoryRatioOfMonthPieData.append(PieChartDataEntry(value: categoryWithCount.count, label: categoryWithCount.name))
                createCategoryRatioOfMonthPieChart(dataEntries: categoryRatioOfMonthPieData)
            }
        } else {
            categoryRatioOfMonthPieData = []
            createCategoryRatioOfMonthPieChart(dataEntries: categoryRatioOfMonthPieData)
        }


        endTaskNumberLabel1.text = String(Int(achieveCount))
        planTaskNumberLabel.text = String(Int(toMonthTasks.count))
        endTaskNumberLabel2.text = String(Int(achieveCount))
        noEndTaskNumberLabel.text = String(Int(toMonthTasks.count) - Int(achieveCount))
        lineChartDescriptionButtomLabel2.text = "日付"
        taskCountSubBarLabel.text = ""
        taskRatioSubBarLabel.text = ""
        categoryRatioSubBarLabel.text = ""

    }

    func calculateAll() {
        var allDateList: [Date] = []
        var endTaskcount = 0.0
        taskCountOfAllChartData = []
        taskRatioOfAllPieData = []
        categoryRatioOfAllPieData = []
        // 達成数計算
        // 一番古い日付を取得
        for task in tasks {
            allDateList.append(task.date)
        }

        if allDateList.isEmpty {
            createTaskCountOfAllLineChart(data: taskCountOfAllChartData)
            createTaskRatioOfAllPieChart(dataEntries: taskRatioOfAllPieData)
            return
        }

        // 後の計算用に
        guard let mostOldDate = allDateList.min(), let mostLatestDate = allDateList.max() else { return }
        // その差から数える月数を取得

        let fromOldToNowMonth = mostOldDate.getMonthCount(fromDate: mostOldDate, toDate: mostLatestDate)

        // その月の回数分だけforを回してtrueの数を調べる
        for i in 0..<fromOldToNowMonth {
            var endTaskOfMonthly: [Task] = []

            endTaskOfMonthly = tasks.filter{
                $0.date.month == mostOldDate.added(year: 0, month: i, day: 0, hour: 0, minute: 0, second: 0).month && $0.date.year == mostOldDate.added(year: 0, month: i, day: 0, hour: 0, minute: 0, second: 0).year && $0.isDone == true
            }
            endTaskcount += Double(endTaskOfMonthly.count)
            taskCountOfAllChartData.append(endTaskcount)
        }
        createTaskCountOfAllLineChart(data: taskCountOfAllChartData)

        //　達成率（円グラフ）計算
        let achieveCount = taskCountOfAllChartData.max() ?? 0
        if allDateList.count != 0 {
            let achieveRatio = ( achieveCount / Double(allDateList.count) ) * 100
            taskRatioOfAllPieData = [
                PieChartDataEntry(value: Double(achieveRatio), label: "達成"),
                PieChartDataEntry(value: Double(100 - achieveRatio), label: "未達成")
            ]
            createTaskRatioOfAllPieChart(dataEntries: taskRatioOfAllPieData)
        } else {
            // "データがありません"と表示させるために意図的に空にする
            taskRatioOfAllPieData = []
            createTaskRatioOfAllPieChart(dataEntries: taskRatioOfAllPieData)
        }

        //　カテゴリ率（円グラフ）計算
        struct CategoryWithCount {
            var name: String = ""
            var count: Double = 0
        }
        var categoryWithCounts: [CategoryWithCount] = []
        var allCounZeroJadge = 0
        if let categories = categoryLists {
            for category in categories {
                let fileterTasks = tasks.filter {
                    $0.category == category && $0.isDone == true
                }
                categoryWithCounts.append(CategoryWithCount.init(name: category.name, count: Double(fileterTasks.count)))
                allCounZeroJadge += fileterTasks.count
            }
        }

        // 達成数が大きい順に並べ替える
        categoryWithCounts = categoryWithCounts.sorted(by: {$1.count < $0.count})

        // nilに分類される未カテゴリをappend
        let fileterTasks = tasks.filter {
            $0.category == nil && $0.isDone == true
        }
        if fileterTasks.count != 0 {
            categoryWithCounts.append(CategoryWithCount.init(name: "未カテゴリ", count: Double(fileterTasks.count)))
            allCounZeroJadge += fileterTasks.count
        }
        // もし全部のデータが0ではなければ画面出力
        if allCounZeroJadge != 0 {
            for categoryWithCount in categoryWithCounts {
                categoryRatioOfAllPieData.append(PieChartDataEntry(value: categoryWithCount.count, label: categoryWithCount.name))
                createCategoryRatioOfAllPieChart(dataEntries: categoryRatioOfAllPieData)
            }
        } else {
            categoryRatioOfAllPieData = []
            createCategoryRatioOfAllPieChart(dataEntries: categoryRatioOfAllPieData)
        }

        endTaskNumberLabel1.text = String(Int(achieveCount))
        planTaskNumberLabel.text = String(Int(allDateList.count))
        endTaskNumberLabel2.text = String(Int(achieveCount))
        noEndTaskNumberLabel.text = String(Int(allDateList.count) - Int(achieveCount))
        lineChartDescriptionButtomLabel2.text = "経過月"
        taskCountSubBarLabel.text = "\(mostOldDate.year)年\(mostOldDate.month)月〜"
        taskRatioSubBarLabel.text = "\(mostOldDate.year)年\(mostOldDate.month)月〜"
        categoryRatioSubBarLabel.text = "\(mostOldDate.year)年\(mostOldDate.month)月〜"
    }

    // MARK: 月間上
    private func createTaskCountOfMonthLineChart(data: [Double]) {
        // プロットデータ(y軸)を保持する配列
        var dataEntries = [ChartDataEntry]()

        for (xValue, yValue) in data.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(xValue), y: yValue)
            dataEntries.append(dataEntry)
        }

        // グラフにデータを適用
        taskCountOfMonthLineDataSet = LineChartDataSet(entries: dataEntries, label: "")
        taskCountOfMonthLineChartView.data = LineChartData(dataSet: taskCountOfMonthLineDataSet)

        // X軸(xAxis)
        taskCountOfMonthLineChartView.xAxis.labelCount = Int(5) //x軸に表示するラベルの数
        taskCountOfMonthLineChartView.xAxis.labelPosition = .bottom // x軸ラベルをグラフの下に表示する
        taskCountOfMonthLineChartView.xAxis.drawGridLinesEnabled = false //x軸のグリッド表示(今回は表示しない)
        taskCountOfMonthLineChartView.xAxis.labelCount = Int(5) //x軸に表示するラベルの数
        taskCountOfMonthLineChartView.xAxis.labelTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) //x軸ラベルの色
        taskCountOfMonthLineChartView.xAxis.axisLineColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) //x軸の色
        taskCountOfMonthLineChartView.xAxis.axisLineWidth = CGFloat(1) //x軸の太さ
        //chartView.xAxis.valueFormatter = lineChartFormatter() //x軸の仕様

        // Y軸(leftAxis/rightAxis)
        taskCountOfMonthLineChartView.rightAxis.enabled = false //右軸(値)の表示
        taskCountOfMonthLineChartView.leftAxis.enabled = true //左軸（値)の表示
        taskCountOfMonthLineChartView.leftAxis.axisMaximum = (data.max() ?? 10) + 5//y左軸最大値
        taskCountOfMonthLineChartView.leftAxis.axisMinimum = 0 //y左軸最小値
        taskCountOfMonthLineChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 11) //y左軸のフォントの大きさ
        taskCountOfMonthLineChartView.leftAxis.labelTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) //y軸ラベルの色
        taskCountOfMonthLineChartView.leftAxis.axisLineColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1) //y左軸の色(今回はy軸消すためにBGと同じ色にしている)
        taskCountOfMonthLineChartView.leftAxis.drawAxisLineEnabled = false //y左軸の表示(今回は表示しない)
        taskCountOfMonthLineChartView.leftAxis.labelCount = Int(4) //y軸ラベルの表示数
        taskCountOfMonthLineChartView.leftAxis.drawGridLinesEnabled = false //y軸のグリッド表示(今回は表示しない)
        taskCountOfMonthLineChartView.leftAxis.gridColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) //y軸グリッドの色

        // その他の変更
        taskCountOfMonthLineChartView.noDataFont = UIFont.systemFont(ofSize: 30) //Noデータ時の表示フォント
        taskCountOfMonthLineChartView.noDataTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Noデータ時の文字色
        taskCountOfMonthLineChartView.noDataText = "表示できるデータがありません" //Noデータ時に表示する文字
        taskCountOfMonthLineChartView.legend.enabled = false //"■ months"のlegendの表示
        taskCountOfMonthLineChartView.dragDecelerationEnabled = true //指を離してもスクロール続くか
        taskCountOfMonthLineChartView.dragDecelerationFrictionCoef = 0.8 //ドラッグ時の減速スピード(0-1)
        //chartView.chartDescription?.text = nil //Description(今回はなし)
        taskCountOfMonthLineChartView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Background Color
        taskCountOfMonthLineChartView.animate(xAxisDuration: 0.7, yAxisDuration: 0.7, easingOption: .linear)
        taskCountOfMonthLineChartView.pinchZoomEnabled = false // ピンチズームオフ
        taskCountOfMonthLineChartView.doubleTapToZoomEnabled = false // ダブルタップズームtaskCountOfMonthLineChartView

        // DateSetの変更
        let gradientColors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).withAlphaComponent(0.3).cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [0.7, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        taskCountOfMonthLineDataSet.fill = LinearGradientFill.init(gradient: gradient!, angle: 90.0)
        taskCountOfMonthLineDataSet.drawCirclesEnabled = false //プロットの表示(今回は表示しない)
        taskCountOfMonthLineDataSet.lineWidth = 3.0 //線の太さ
        //chartDataSet.circleRadius = 0 //プロットの大きさ
        taskCountOfMonthLineDataSet.drawCirclesEnabled = false //プロットの表示taskCountOfMonthChartDataSet
        taskCountOfMonthLineDataSet.mode = .cubicBezier //曲線にする
        taskCountOfMonthLineDataSet.fillAlpha = 0.8 //グラフの透過率(曲線は投下しない)
        taskCountOfMonthLineDataSet.drawFilledEnabled = true //グラフ下の部分塗りつぶし
        //taskCountOfMonthChartDataSet.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //グラフ塗りつぶし色
        taskCountOfMonthLineDataSet.drawValuesEnabled = false //各プロットのラベル表示(今回は表示しない)
        taskCountOfMonthLineDataSet.highlightColor = #colorLiteral(red: 1, green: 0.8392156959, blue: 0.9764705896, alpha: 1) //各点を選択した時に表示されるx,yの線
        taskCountOfMonthLineDataSet.colors = [#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)] //Drawing graph
    }

    // MARK: 月間真ん中
    private func createTaskRatioOfMonthPieChart(dataEntries: [PieChartDataEntry]) {
        taskRatioOfMonthPieChartView.noDataText = "表示できるデータがありません"
        taskRatioOfMonthPieChartView.drawHoleEnabled = false //中心まで塗りつぶし
        taskRatioOfMonthPieChartView.highlightPerTapEnabled = false  // グラフがタップされたときのハイライトをOFF（任意）
        taskRatioOfMonthPieChartView.chartDescription.enabled = false  // グラフの説明を非表示
        taskRatioOfMonthPieChartView.drawEntryLabelsEnabled = false  // グラフ上のデータラベルを非表示
        taskRatioOfMonthPieChartView.rotationEnabled = false // グラフがぐるぐる動くのを無効化
        taskRatioOfMonthPieChartView.legend.enabled = true  // グラフの注釈
        taskRatioOfMonthPieChartView.legend.formSize = CGFloat(20)

        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        // グラフの色
        dataSet.colors = [#colorLiteral(red: 0.9219940305, green: 0.662347734, blue: 0.6161623597, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)]
        // グラフのデータの値の色
        dataSet.valueTextColor = UIColor.gray
        // グラフのデータのタイトルの色
        dataSet.entryLabelColor = UIColor.black

        // データがないときにnoDataTextを表示させる
        if dataEntries.isEmpty == false {
            taskRatioOfMonthPieChartView.data = PieChartData(dataSet: dataSet)
        } else {
            taskRatioOfMonthPieChartView.data = nil
        }

        // データを％表示にする
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        taskRatioOfMonthPieChartView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        taskRatioOfMonthPieChartView.usePercentValuesEnabled = true
        taskRatioOfMonthPieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }

    // MARK: 月間下
    private func createCategoryRatioOfMonthPieChart(dataEntries: [PieChartDataEntry]) {
        categoryRatioOfMonthPieChartView.noDataText = "表示できるデータがありません"
        categoryRatioOfMonthPieChartView.drawHoleEnabled = false //中心まで塗りつぶし
        categoryRatioOfMonthPieChartView.highlightPerTapEnabled = false  // グラフがタップされたときのハイライトをOFF（任意）
        categoryRatioOfMonthPieChartView.chartDescription.enabled = false  // グラフの説明を非表示
        categoryRatioOfMonthPieChartView.drawEntryLabelsEnabled = false  // グラフ上のデータラベルを非表示
        categoryRatioOfMonthPieChartView.rotationEnabled = false // グラフがぐるぐる動くのを無効化
        categoryRatioOfMonthPieChartView.legend.enabled = true  // グラフの注釈
        categoryRatioOfMonthPieChartView.legend.formSize = CGFloat(15)
        categoryRatioOfMonthPieChartView.legend.formToTextSpace = CGFloat(5)
        categoryRatioOfMonthPieChartView.legend.xEntrySpace = CGFloat(10)
        categoryRatioOfMonthPieChartView.legend.yEntrySpace = CGFloat(13)

        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        // グラフの色
        dataSet.colors = [#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.917396605, green: 0.7570750117, blue: 0.9239473939, alpha: 1), #colorLiteral(red: 0.9768630862, green: 0.8991695642, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9521791339, blue: 0, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.6560183516, blue: 0.6063735112, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.7878945572, alpha: 1), #colorLiteral(red: 0.917396605, green: 0.7570750117, blue: 0.7828175044, alpha: 1), #colorLiteral(red: 0.9768630862, green: 0.8991695642, blue: 0.6977040816, alpha: 1), #colorLiteral(red: 0, green: 0.9521791339, blue: 0.637542517, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.4891350561, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.780015445, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.917396605, green: 0.7570750117, blue: 0.9239473939, alpha: 1), #colorLiteral(red: 0.9768630862, green: 0.8991695642, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9521791339, blue: 0, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.6560183516, blue: 0.6063735112, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.7878945572, alpha: 1), #colorLiteral(red: 0.917396605, green: 0.7570750117, blue: 0.7828175044, alpha: 1), #colorLiteral(red: 0.9768630862, green: 0.8991695642, blue: 0.6977040816, alpha: 1), #colorLiteral(red: 0, green: 0.9521791339, blue: 0.637542517, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.4891350561, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.780015445, alpha: 1)]

        // 未カテゴリだけ色を灰色にする
        let filterTask = dataEntries.filter{ $0.label == "未カテゴリ" }
        if !filterTask.isEmpty {
            dataSet.colors[dataEntries.count - 1] = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
        }

        // グラフのデータの値の色
        dataSet.valueTextColor = UIColor.gray
        // グラフのデータのタイトルの色
        dataSet.entryLabelColor = UIColor.black

        // データがないときにnoDataTextを表示させる
        if dataEntries.isEmpty == false {
            categoryRatioOfMonthPieChartView.data = PieChartData(dataSet: dataSet)
        } else {
            categoryRatioOfMonthPieChartView.data = nil
        }

        // データを％表示にする
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        formatter.minimumFractionDigits = 0
        categoryRatioOfMonthPieChartView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        categoryRatioOfMonthPieChartView.usePercentValuesEnabled = false
        categoryRatioOfMonthPieChartView.animate(xAxisDuration: 2.5, yAxisDuration: 2.5)
    }

    // MARK: 総合上
    private func createTaskCountOfAllLineChart(data: [Double]) {

        // プロットデータ(y軸)を保持する配列
        var dataEntries = [ChartDataEntry]()

        for (xValue, yValue) in data.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(xValue+1), y: yValue)
            dataEntries.append(dataEntry)
        }

        // ２ヶ月以上のデータがなければ表示させない
        if dataEntries.count >= 2 {
            lineChartDescriptionButtomLabel2.text = "経過月"
            lineChartDescriptionTopLabel2.text = "達成タスク数"
            taskCountOfAllLineDataSet = LineChartDataSet(entries: dataEntries, label: "")
            taskCountOfAllLineChartView.data = LineChartData(dataSet: taskCountOfAllLineDataSet)
        } else {
            lineChartNoDataLabel.text = """
                   表示できるデータ量がありません
                   ２ヶ月以上の達成データが必要です
                   """
            lineChartDescriptionButtomLabel2.isHidden = true
            lineChartDescriptionTopLabel2.isHidden = true
            endTaskLabel.isHidden = true
            endTaskNumberLabel1.isHidden = true

            taskCountOfAllLineChartView.isHidden = true
            return
        }

        // X軸(xAxis)
        taskCountOfAllLineChartView.xAxis.labelPosition = .bottom // x軸ラベルをグラフの下に表示する
        taskCountOfAllLineChartView.xAxis.drawGridLinesEnabled = false //x軸のグリッド表示(今回は表示しない)
        // taskCountOfAllLineChartView.xAxis.labelCount = Int(2) //x軸に表示するラベルの数
        taskCountOfAllLineChartView.xAxis.labelTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) //x軸ラベルの色
        taskCountOfAllLineChartView.xAxis.axisLineColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) //x軸の色
        taskCountOfAllLineChartView.xAxis.axisLineWidth = CGFloat(1)
        //x軸の太さ
        taskCountOfAllLineChartView.xAxis.axisMinimum = 1
        // x軸に表示させるラベルの数をデータの数によって変える
        if data.count <= 3 {
            taskCountOfAllLineChartView.xAxis.labelCount = Int(2)
        } else if 3 < data.count && data.count <= 12 {
            taskCountOfAllLineChartView.xAxis.labelCount = Int(3)
        } else {
            taskCountOfAllLineChartView.xAxis.labelCount = Int(5)
        }

        // Y軸(leftAxis/rightAxis)
        taskCountOfAllLineChartView.rightAxis.enabled = false //右軸(値)の表示
        taskCountOfAllLineChartView.leftAxis.enabled = true //左軸（値)の表示
        taskCountOfAllLineChartView.leftAxis.axisMaximum = (data.max() ?? 10) + 10//y左軸最大値
        taskCountOfAllLineChartView.leftAxis.axisMinimum = 0 //y左軸最小値
        taskCountOfAllLineChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 11) //y左軸のフォントの大きさ
        taskCountOfAllLineChartView.leftAxis.labelTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) //y軸ラベルの色
        taskCountOfAllLineChartView.leftAxis.axisLineColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1) //y左軸の色(今回はy軸消すためにBGと同じ色にしている)
        taskCountOfAllLineChartView.leftAxis.drawAxisLineEnabled = false //y左軸の表示(今回は表示しない)
        taskCountOfAllLineChartView.leftAxis.labelCount = Int(4) //y軸ラベルの表示数
        taskCountOfAllLineChartView.leftAxis.drawGridLinesEnabled = false //y軸のグリッド表示(今回は表示しない)
        taskCountOfAllLineChartView.leftAxis.gridColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) //y軸グリッドの色

        // その他の変更
        taskCountOfAllLineChartView.noDataFont = UIFont.systemFont(ofSize: 30) //Noデータ時の表示フォント
        taskCountOfAllLineChartView.noDataTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Noデータ時の文字色
        taskCountOfAllLineChartView.legend.enabled = false //"■ months"のlegendの表示
        taskCountOfAllLineChartView.dragDecelerationEnabled = true //指を離してもスクロール続くか
        taskCountOfAllLineChartView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Background Color
        taskCountOfAllLineChartView.pinchZoomEnabled = false // ピンチズームオフ
        taskCountOfAllLineChartView.doubleTapToZoomEnabled = false // ダブルタップズームtaskCountOfMonthLineChartView

        // DateSetの変更
        let gradientColors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).withAlphaComponent(0.3).cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [0.7, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        taskCountOfAllLineDataSet.fill = LinearGradientFill.init(gradient: gradient!, angle: 90.0)
        taskCountOfAllLineDataSet.drawCirclesEnabled = false //プロットの表示(今回は表示しない)
        taskCountOfAllLineChartView.animate(xAxisDuration: 0, yAxisDuration: 1.0, easingOption: .easeOutBack)
        taskCountOfAllLineDataSet.lineWidth = 3.0 //線の太さ
        taskCountOfAllLineChartView.noDataText = "表示できるデータがありません" //Noデータ時に表示する文字
        taskCountOfAllLineDataSet.drawCirclesEnabled = false //プロットの表示taskCountOfMonthChartDataSet
        taskCountOfAllLineDataSet.mode = .cubicBezier //曲線にする
        taskCountOfAllLineDataSet.fillAlpha = 0.8 //グラフの透過率(曲線は投下しない)
        taskCountOfAllLineDataSet.drawFilledEnabled = true //グラフ下の部分塗りつぶし
        taskCountOfAllLineDataSet.drawValuesEnabled = false //各プロットのラベル表示(今回は表示しない)
        taskCountOfAllLineDataSet.highlightColor = #colorLiteral(red: 1, green: 0.8392156959, blue: 0.9764705896, alpha: 1) //各点を選択した時に表示されるx,yの線
        taskCountOfAllLineDataSet.colors = [#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)] //Drawing graph
    }

    // MARK: 総合中
    private func createTaskRatioOfAllPieChart(dataEntries: [PieChartDataEntry]) {
        taskRatioOfAllPieChartView.noDataText = "表示できるデータがありません"
        taskRatioOfAllPieChartView.drawHoleEnabled = false //中心まで塗りつぶし
        taskRatioOfAllPieChartView.highlightPerTapEnabled = false  // グラフがタップされたときのハイライトをOFF（任意）
        taskRatioOfAllPieChartView.chartDescription.enabled = false  // グラフの説明を非表示
        taskRatioOfAllPieChartView.drawEntryLabelsEnabled = false  // グラフ上のデータラベルを非表示
        taskRatioOfAllPieChartView.rotationEnabled = false // グラフがぐるぐる動くのを無効化
        taskRatioOfAllPieChartView.legend.enabled = true  // グラフの注釈
        taskRatioOfAllPieChartView.legend.formSize = CGFloat(20)

        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        // グラフの色
        dataSet.colors = [#colorLiteral(red: 0.9219940305, green: 0.662347734, blue: 0.6161623597, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)]
        // グラフのデータの値の色
        dataSet.valueTextColor = UIColor.gray
        // グラフのデータのタイトルの色
        dataSet.entryLabelColor = UIColor.black

        // データがないときにnoDataTextを表示させる
        if dataEntries.isEmpty == false {
            taskRatioOfAllPieChartView.data = PieChartData(dataSet: dataSet)
        } else {
            taskRatioOfAllPieChartView.data = nil
        }

        // データを％表示にする
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1.0
        taskRatioOfAllPieChartView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        taskRatioOfAllPieChartView.usePercentValuesEnabled = true
        taskRatioOfAllPieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }

    // MARK: 総合下
    private func createCategoryRatioOfAllPieChart(dataEntries: [PieChartDataEntry]) {
        categoryRatioOfAllPieChartView.noDataText = "表示できるデータがありません"
        categoryRatioOfAllPieChartView.drawHoleEnabled = false //中心まで塗りつぶし
        categoryRatioOfAllPieChartView.highlightPerTapEnabled = false  // グラフがタップされたときのハイライトをOFF（任意）
        categoryRatioOfAllPieChartView.chartDescription.enabled = false  // グラフの説明を非表示
        categoryRatioOfAllPieChartView.drawEntryLabelsEnabled = false  // グラフ上のデータラベルを非表示
        categoryRatioOfAllPieChartView.rotationEnabled = false // グラフがぐるぐる動くのを無効化
        categoryRatioOfAllPieChartView.legend.formSize = CGFloat(15)
        categoryRatioOfAllPieChartView.legend.formToTextSpace = CGFloat(5)
        categoryRatioOfAllPieChartView.legend.xEntrySpace = CGFloat(10)
        categoryRatioOfAllPieChartView.legend.yEntrySpace = CGFloat(13)

        let dataSet = PieChartDataSet(entries: dataEntries, label: "")

        // グラフの色
        dataSet.colors = [#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.917396605, green: 0.7570750117, blue: 0.9239473939, alpha: 1), #colorLiteral(red: 0.9768630862, green: 0.8991695642, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9521791339, blue: 0, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.6560183516, blue: 0.6063735112, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.7878945572, alpha: 1), #colorLiteral(red: 0.917396605, green: 0.7570750117, blue: 0.7828175044, alpha: 1), #colorLiteral(red: 0.9768630862, green: 0.8991695642, blue: 0.6977040816, alpha: 1), #colorLiteral(red: 0, green: 0.9521791339, blue: 0.637542517, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.4891350561, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.780015445, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.917396605, green: 0.7570750117, blue: 0.9239473939, alpha: 1), #colorLiteral(red: 0.9768630862, green: 0.8991695642, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9521791339, blue: 0, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.6560183516, blue: 0.6063735112, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.7878945572, alpha: 1), #colorLiteral(red: 0.917396605, green: 0.7570750117, blue: 0.7828175044, alpha: 1), #colorLiteral(red: 0.9768630862, green: 0.8991695642, blue: 0.6977040816, alpha: 1), #colorLiteral(red: 0, green: 0.9521791339, blue: 0.637542517, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.4891350561, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.780015445, alpha: 1)]

        // 未カテゴリだけ色を灰色にする
        let filterTask = dataEntries.filter{ $0.label == "未カテゴリ" }
        if !filterTask.isEmpty {
            dataSet.colors[dataEntries.count - 1] = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
        }

        // グラフのデータの値の色
        dataSet.valueTextColor = UIColor.gray
        // グラフのデータのタイトルの色
        dataSet.entryLabelColor = UIColor.black

        // データがないときにnoDataTextを表示させる
        if dataEntries.isEmpty == false {
            categoryRatioOfAllPieChartView.data = PieChartData(dataSet: dataSet)
        } else {
            categoryRatioOfAllPieChartView.data = nil
        }

        // データを％表示にする
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        formatter.minimumFractionDigits = 0
        categoryRatioOfAllPieChartView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        categoryRatioOfAllPieChartView.usePercentValuesEnabled = false
        categoryRatioOfAllPieChartView.animate(xAxisDuration: 2.5, yAxisDuration: 2.5)
    }

    // グラフを描画するときに必ずこの関数を呼ぶ
    private func presentMonthOrAll(isMonth: Bool) {
        lineChartNoDataLabel.text = ""
        if isMonth {
            beforeMonthButton.isEnabled = true
            afterMonthButton.isEnabled = true
            self.navigationItem.title = "\(presentDate.year)年\(presentDate.month)月"
            taskCountOfMonthLineChartView.isHidden = false
            taskRatioOfMonthPieChartView.isHidden = false
            categoryRatioOfMonthPieChartView.isHidden = false
            taskCountOfAllLineChartView.isHidden = true
            taskRatioOfAllPieChartView.isHidden = true
            categoryRatioOfAllPieChartView.isHidden = true
            calculateMonth()
        } else {
            beforeMonthButton.isEnabled = false
            afterMonthButton.isEnabled = false
            self.navigationItem.title = "総合"
            taskCountOfMonthLineChartView.isHidden = true
            taskRatioOfMonthPieChartView.isHidden = true
            categoryRatioOfMonthPieChartView.isHidden = true
            taskCountOfAllLineChartView.isHidden = false
            taskRatioOfAllPieChartView.isHidden = false
            categoryRatioOfAllPieChartView.isHidden = false
            calculateAll()
        }
    }
}

extension Array {
    subscript (element index: Index) -> Element? {
        //　MARK: 配列の要素以上を指定していたらnilを返すようにする
        indices.contains(index) ? self[index] : nil
    }
}
