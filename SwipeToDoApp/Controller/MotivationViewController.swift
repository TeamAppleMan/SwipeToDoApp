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

    private var categoryLists: Results<CategoryList>!
    private var tasks: Results<Task>!
    private var presentDate: Date!

    @IBOutlet weak var taskRangeSegmentedControl: UISegmentedControl!

    // 赤・青・緑のトップバーのLabel
    @IBOutlet private weak var taskCountTopBarLabel: UILabel!
    @IBOutlet private weak var taskRatioTopBarLabel: UILabel!
    @IBOutlet private weak var categoryRatioTopBarLabel: UILabel!
    @IBOutlet private weak var taskCountSubBarLabel: UILabel!
    @IBOutlet private weak var taskRatioSubBarLabel: UILabel!
    @IBOutlet private weak var categoryRatioSubBarLabel: UILabel!

    @IBOutlet private weak var taskCountOfMonthLineChartView: LineChartView!
    @IBOutlet private weak var taskRatioOfMonthPieChartView: PieChartView!
    @IBOutlet private weak var categoryRatioOfMonthPieChartView: PieChartView!
    private var taskCountOfMonthChartDataSet: LineChartDataSet!
    private var taskRatioOfMonthPieDataSet: PieChartDataSet!
    private var categoryRatioOfMonthPieDataSet: PieChartDataSet!

    private var taskCountOfMonthChartData: [Double] = []
    private var taskRatioOfMonthPieData: [PieChartDataEntry] = []
    private var categoryRatioOfMonthPieData: [PieChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // 赤・青・緑部分を角丸にする
        taskCountTopBarLabel.layer.cornerRadius = 15
        taskCountTopBarLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        taskCountTopBarLabel.clipsToBounds = true
        taskRatioTopBarLabel.layer.cornerRadius = 15
        taskRatioTopBarLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        taskRatioTopBarLabel.clipsToBounds = true
        categoryRatioTopBarLabel.layer.cornerRadius = 15
        categoryRatioTopBarLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        categoryRatioTopBarLabel.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm()
        tasks = realm.objects(Task.self)
        categoryLists = realm.objects(CategoryList.self)

        // 今日を取得して、データに格納
        let calPosition = Calendar.current
        let todayComppnent = calPosition.dateComponents(
            [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,
             Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second],
             from: Date())
        presentDate = Date.init(year: todayComppnent.year, month: todayComppnent.month, day: 2, hour: 0, minute: 0, second: 0 )
        self.navigationItem.title = "\(presentDate.year)年\(presentDate.month)月"

        calculateMonth()
    }

    @IBAction private func didTapFrontMonthButton(_ sender: Any) {
        presentDate = presentDate.added(year: 0, month: -1, day: 0, hour: 0, minute: 0, second: 0)
        self.navigationItem.title = "\(presentDate.year)年\(presentDate.month)月"
    }

    @IBAction private func didTapNextMonthButton(_ sender: Any) {
        presentDate = presentDate.added(year: 0, month: 1, day: 0, hour: 0, minute: 0, second: 0)
        self.navigationItem.title = "\(presentDate.year)年\(presentDate.month)月"
    }

    private func calculateMonth() {
        var filterTasks:[Task] = []
        // トップの折れ線グラフの計算
        // 当月のTaskかどうかをfilterする
        filterTasks = tasks.filter {
            presentDate < $0.date && $0.date < presentDate.added(year: 0, month: 1, day: 0, hour: 0, minute: 0, second: 0)
        }
        for i in 0..<presentDate.getMonthLastDay(MonthLastDate: presentDate){
            var countArray: [Task] = []

            countArray = filterTasks.filter{
                $0.date == presentDate.added(year: 0, month: 0, day: i, hour: 0, minute: 0, second: 0) && $0.isDone == true
            }
            taskCountOfMonthChartData.append(Double(countArray.count))
        }
        createTaskCountOfMonthLineChart(data: taskCountOfMonthChartData)
        print(taskCountOfMonthChartData)

        //　達成率（円グラフ）計算
        let achieveCount = taskCountOfMonthChartData.reduce(0, +)
        let achieveRatio = ( achieveCount / Double(taskCountOfMonthChartData.count) ) * 100
        taskRatioOfMonthPieData = [
                PieChartDataEntry(value: Double(achieveRatio), label: "達成"),
                PieChartDataEntry(value: Double(100 - achieveRatio), label: "未達成")
            ]
        createTaskRatioOfMonthPieChart(dataEntries: taskRatioOfMonthPieData)

        // カテゴリー割合計算
        var specificCategoriesTask: [Task] = []
        var data3: [Int] = []
        taskRatioOfMonthPieData.removeAll()
        for category in categoryLists {
            // カテゴリをfilterしてappend
            specificCategoriesTask = filterTasks.filter{
                $0.category == category.name
            }
            data3.append(specificCategoriesTask.count)
            taskRatioOfMonthPieData.append(PieChartDataEntry(value: Double(specificCategoriesTask.count), label: category.name))
        }
        createCategoryRatioOfMonthPieChart(dataEntries: taskRatioOfMonthPieData)
    }

    private func createTaskCountOfMonthLineChart(data: [Double]) {
        // プロットデータ(y軸)を保持する配列
        var dataEntries = [ChartDataEntry]()

        for (xValue, yValue) in data.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(xValue), y: yValue)
            dataEntries.append(dataEntry)
        }
        // グラフにデータを適用
        taskCountOfMonthChartDataSet = LineChartDataSet(entries: dataEntries, label: "SampleDataChart")
        taskCountOfMonthLineChartView.data = LineChartData(dataSet: taskCountOfMonthChartDataSet)

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
        taskCountOfMonthLineChartView.noDataText = "Keep Waiting" //Noデータ時に表示する文字
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
        taskCountOfMonthChartDataSet.fill = LinearGradientFill.init(gradient: gradient!, angle: 90.0)
        taskCountOfMonthChartDataSet.drawCirclesEnabled = false //プロットの表示(今回は表示しない)
        taskCountOfMonthChartDataSet.lineWidth = 3.0 //線の太さ
        //chartDataSet.circleRadius = 0 //プロットの大きさ
        taskCountOfMonthChartDataSet.drawCirclesEnabled = false //プロットの表示taskCountOfMonthChartDataSet
        taskCountOfMonthChartDataSet.mode = .cubicBezier //曲線にする
        taskCountOfMonthChartDataSet.fillAlpha = 0.8 //グラフの透過率(曲線は投下しない)
        taskCountOfMonthChartDataSet.drawFilledEnabled = true //グラフ下の部分塗りつぶし
        //taskCountOfMonthChartDataSet.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //グラフ塗りつぶし色
        taskCountOfMonthChartDataSet.drawValuesEnabled = false //各プロットのラベル表示(今回は表示しない)
        taskCountOfMonthChartDataSet.highlightColor = #colorLiteral(red: 1, green: 0.8392156959, blue: 0.9764705896, alpha: 1) //各点を選択した時に表示されるx,yの線
        taskCountOfMonthChartDataSet.colors = [#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)] //Drawing graph
        taskCountOfMonthLineChartView.isHidden = false
    }

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
        taskRatioOfMonthPieChartView.isHidden = false
    }

    private func createCategoryRatioOfMonthPieChart(dataEntries: [PieChartDataEntry]) {
        categoryRatioOfMonthPieChartView.noDataText = "表示できるデータがありません"
        categoryRatioOfMonthPieChartView.drawHoleEnabled = false //中心まで塗りつぶし
        categoryRatioOfMonthPieChartView.highlightPerTapEnabled = false  // グラフがタップされたときのハイライトをOFF（任意）
        categoryRatioOfMonthPieChartView.chartDescription.enabled = false  // グラフの説明を非表示
        categoryRatioOfMonthPieChartView.drawEntryLabelsEnabled = false  // グラフ上のデータラベルを非表示
        categoryRatioOfMonthPieChartView.rotationEnabled = false // グラフがぐるぐる動くのを無効化
        categoryRatioOfMonthPieChartView.legend.enabled = true  // グラフの注釈
        categoryRatioOfMonthPieChartView.legend.formSize = CGFloat(20)

        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        // グラフの色
        dataSet.colors = [#colorLiteral(red: 0.9219940305, green: 0.662347734, blue: 0.6161623597, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)]
        //dataSet.colors = ChartColorTemplates.vordiplom()
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
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        categoryRatioOfMonthPieChartView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        categoryRatioOfMonthPieChartView.usePercentValuesEnabled = true
        categoryRatioOfMonthPieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        categoryRatioOfMonthPieChartView.isHidden = false
    }

}
