//
//  ViewController.swift
//  MemoryLeaks
//
//  Created by 유준용 on 2022/03/11.
//

import UIKit

class ViewController: UIViewController {

    let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Tab me", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTabButton), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
        makeMemoryLeaks()
    }

    private func configureUI(){
        view.addSubview(createButton)
        view.backgroundColor = .lightGray
        NSLayoutConstraint.activate([
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    private func makeMemoryLeaks(){
        let a = A()
        let b = B()
        a.b = b
        b.a = a
    }
    
    @objc private func didTabButton(){ // 버튼 tab시
        let secondVC = SecondVC()
        self.present(secondVC, animated: true, completion: nil)
    }

}

class A{
    var b: B?
}
class B{
    var a: A?
}


class MyView: UIView{
    var vc: UIViewController?
    init(vc: UIViewController) {
        self.vc = vc
        print("MyView", #function)
        super.init(frame: .zero)
    }
    deinit{
        print("MyView", #function)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

class SecondVC: UIViewController {
    var myView: MyView?
    
    let dismissButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Dismiss", for: .normal)
        btn.addTarget(self, action: #selector(dismissSecondVC), for: .touchUpInside)
        return btn
    }()
    
    @objc func dismissSecondVC(){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    deinit {
        print("SecondVC", #function)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        view.backgroundColor = .red
        self.myView = MyView(vc: self)
        
        
    }
    
    private func configureUI(){
        view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
}
