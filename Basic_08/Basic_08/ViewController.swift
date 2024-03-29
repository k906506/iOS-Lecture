//
//  ViewController.swift
//  Basic_08
//
//  Created by 고도 on 2022/09/23.
//

import UIKit

import Alamofire
import Charts

class ViewController: UIViewController {
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var newCaseLabel: UILabel!
    @IBOutlet weak var totalCaseLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var labelStackView: UIStackView!
    
    let apiKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicatorView.startAnimating()
        self.fetchCovidOverview(completionHandler: { [weak self] result in
            guard let self = self else { return } // self에 대한 옵셔널 바인딩
            
            switch result {
            case let.success(result):
                self.configureStackView(koreaCovidOverview: result.korea)
                let covidOverviewList = self.makeCovidOverviewList(cityCovidOverview: result)
                self.configureChartView(covidOverviewList: covidOverviewList)
                
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
                self.labelStackView.isHidden = false
                self.pieChartView.isHidden = false
                
//                URLSession으로 API를 호출할 때의 코드, fetchCovidOverviewToURLSession 함수로 변경해줄 것!
//
//                DispatchQueue.main.async {
//                    self.configureStackView(koreaCovidOverview: result.korea)
//                    let covidOverviewList = self.makeCovidOverviewList(cityCovidOverview: result)
//                    self.configureChartView(covidOverviewList: covidOverviewList)
//
//                    self.indicatorView.stopAnimating()
//                    self.indicatorView.isHidden = true
//                    self.labelStackView.isHidden = false
//                    self.pieChartView.isHidden = false
//                }
                
            case let.failure(error):
                debugPrint("error \(error)")
            }
            
        })
    }
    
    func makeCovidOverviewList(
        cityCovidOverview: CityCovidOverview
    ) -> [CovidOverview] {
        return [
            cityCovidOverview.seoul,
            cityCovidOverview.busan,
            cityCovidOverview.daegu,
            cityCovidOverview.incheon,
            cityCovidOverview.gwangju,
            cityCovidOverview.daejeon,
            cityCovidOverview.ulsan,
            cityCovidOverview.sejong,
            cityCovidOverview.gyeonggi,
            cityCovidOverview.chungbuk,
            cityCovidOverview.chungnam,
            cityCovidOverview.gyeongbuk,
            cityCovidOverview.gyeongnam,
            cityCovidOverview.jeju
        ]
    }
    
    func configureChartView(covidOverviewList: [CovidOverview]) -> Void {
        self.pieChartView.delegate = self
        
        let entries = covidOverviewList
            .sorted(by: { $0.incDecK > $1.incDecK})
            .compactMap { [weak self] overview -> PieChartDataEntry? in
                guard let self = self else { return nil }
                return PieChartDataEntry(
                    value: self.removeFormatString(string: "\(overview.incDec)"),
                    label: overview.countryNm,
                    data: overview
                )
            }
        
        let dataSet = PieChartDataSet(entries: entries, label: "코로나 발생 현황")
        dataSet.sliceSpace = 1
        dataSet.entryLabelColor = .black
        dataSet.valueTextColor = .black
        dataSet.xValuePosition = .outsideSlice
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.2
        dataSet.valueLinePart2Length = 0.3
        
        dataSet.colors = ChartColorTemplates.vordiplom() +
        ChartColorTemplates.joyful() +
        ChartColorTemplates.liberty() +
        ChartColorTemplates.pastel() +
        ChartColorTemplates.material()
        
        self.pieChartView.data = PieChartData(dataSet: dataSet)
    }
    
    func removeFormatString(string: String) -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: string)?.doubleValue ?? 0
    }
    
    func configureStackView(koreaCovidOverview: CovidOverview) {
        self.totalCaseLabel.text = "\(koreaCovidOverview.totalCnt)명"
        self.newCaseLabel.text = "\(koreaCovidOverview.incDec)명"
    }
    
    func fetchCovidOverview (
        completionHandler: @escaping (Result<CityCovidOverview, Error>) -> Void
    ) {
        let url: String = "https://api.corona-19.kr/korea/beta/"
        let param = [
            "serviceKey": "\(apiKey)"
        ]
        
        AF.request(url, method: .get, parameters: param)
            .responseData(completionHandler: {response in
                switch response.result {
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(CityCovidOverview.self, from: data)
                        completionHandler(.success(result))
                    } catch {
                        completionHandler(.failure(error))
                    }
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            })
    }
    
//    URLSession으로 API를 호출할 때의 코드
//
//    func fetchCovidOverviewToURLSession(
//        completionHandler: @escaping (Result<CityCovidOverview, Error>) -> Void
//    ) {
//        let session: URLSession = URLSession(configuration: .default)
//        let baseURL: String = "https://api.corona-19.kr/korea/beta/?serviceKey=\(apiKey)"
//
//        guard let url: URL = URL(string: baseURL) else { return }
//
//        session.dataTask(with: url) { data, response, error in
//            if let error {
//                completionHandler(.failure(error))
//            }
//
//            if let data = data {
//                do {
//                    let result = try JSONDecoder().decode(CityCovidOverview.self, from: data)
//                    debugPrint(result)
//                    completionHandler(.success(result))
//                } catch(let error) {
//                    completionHandler(.failure(error))
//                }
//            }
//        }.resume()
//    }
}

extension ViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let covidDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CovidDetailTableViewController") as? CovidDetailTableViewController else { return }
        guard let covidOverView = entry.data as? CovidOverview else { return }
        covidDetailViewController.covidOverView = covidOverView
        self.navigationController?.pushViewController(covidDetailViewController, animated: true)
    }
}
