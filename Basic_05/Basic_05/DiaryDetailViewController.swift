//
//  DiartyDetailViewController.swift
//  Basic_05
//
//  Created by 고도 on 2022/09/06.
//

import UIKit

protocol DiaryDetailViewDelegate : AnyObject {
    func didSelectDelect(indexPath : IndexPath)
}

class DiaryDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView : UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate : DiaryDetailViewDelegate?
    
    var diary : Diary?
    var indexPath : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
    }
    
    private func dateToString(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @IBAction func tapEditButton(_ sender: UIButton) {
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        self.delegate?.didSelectDelect(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
}
