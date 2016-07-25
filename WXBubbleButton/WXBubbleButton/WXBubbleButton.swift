
//
//  WXBubbleButton.swift
//
//  Created by 魏翔 on 16/7/22.
//  Copyright © 2016年 魏翔. All rights reserved.
//

import UIKit

class WXBubbleButton: UIButton {
    
    override init(frame: CGRect) {super.init(frame: frame);viewprepare()}
    
    required init?(coder aDecoder: NSCoder) {super.init(coder: aDecoder);}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        viewprepare()
        
    }
    
    var title: String?{
        
        didSet{
        
            setTitle(title, forState: .Normal)
            
            titleLabel?.font = UIFont.systemFontOfSize(11)
            
        }
        
    }
    
    private var originalR: CGFloat = 0
    
    private let maxDistance: CGFloat = 100
    
    private var originalCenter: CGPoint = CGPointZero
    
    private var isOverBorder: Bool = false
    
    private var parentView = UIView?()
    
    private lazy var smallCircleView: UIView = {
        
        let smallCircleView = UIView()
        
        smallCircleView.center = self.center
        
        smallCircleView.bounds.size = self.frame.size
        
        smallCircleView.layer.cornerRadius = self.originalR
        
        smallCircleView.layer.masksToBounds = true
        
        smallCircleView.backgroundColor = self.backgroundColor
        
        smallCircleView.hidden = true
        
        return smallCircleView
        
    }()
    
    private lazy var shapeLayer: CAShapeLayer = {
        
        let shapLayer = CAShapeLayer()
        
        shapLayer.fillColor = self.backgroundColor!.CGColor
        
        return shapLayer
        
    }()
    
    func viewprepare(){
        
        //注册手势
        let panGesture = UIPanGestureRecognizer(target: self, action: "didPanGesture:")
        
        addGestureRecognizer(panGesture)
        
        if self.backgroundColor == nil{
            self.backgroundColor = UIColor.redColor()
        }
        
        self.parentView = superview
        
        if let parentView = parentView{
            parentView.insertSubview(smallCircleView, belowSubview: self)
        }
        
    }
    
    //从代码添加
    func showIn(parentView: UIView){
        
        self.parentView = parentView
        
        parentView.addSubview(self)
        
        parentView.insertSubview(smallCircleView, belowSubview: self)

    }
    
    func didPanGesture(pangesture: UIPanGestureRecognizer){
        
        //计算圆心距离
        let distance = distanceWith(smallCenter: center, bigCenter: smallCircleView.center)
        
        if pangesture.state == .Changed{
        
            let panPoint = pangesture.translationInView(self)
            //形变
            center.x += panPoint.x
            center.y += panPoint.y
            //改变小圆大小
            let smallR = originalR - (distance / 10)
            
            smallCircleView.bounds = CGRectMake(0, 0, 2 * smallR, 2 * smallR)
            
            smallCircleView.layer.cornerRadius = smallR
            
            smallCircleView.layer.masksToBounds = true
            
            // 超过最大圆心距离,不需要描述形变矩形
            if (distance > maxDistance){
                //超过边界
                isOverBorder = true
                //隐藏小圆
                smallCircleView.hidden = true
                //没有弹性效果
                shapeLayer.removeFromSuperlayer()
                
            }else if(distance > 0 && isOverBorder == false){//设置小圆圆心，并且描述形变矩形
                
                smallCircleView.hidden = false
                
                shapeLayer.path = pathWith(smallCircleView.center, smallRadius: smallR, bigCenter: center, bigRadius: originalR).CGPath
                
                superview?.layer.insertSublayer(shapeLayer, below: smallCircleView.layer)
                
            }
            //复位
            pangesture.setTranslation(CGPointZero, inView: self)
            
        }else if pangesture.state == .Ended{
            
            if (distance > maxDistance){
                setUpBoom()
            }else{
                setUpReset()
            }
            
        }
        
    }
    
    // 描述形变路径
    private func pathWith(smallCenter:CGPoint, smallRadius:CGFloat, bigCenter: CGPoint, bigRadius: CGFloat) -> UIBezierPath
    {
    
        // 获取小圆x1和y1
        let x1 = smallCenter.x
        let y1 = smallCenter.y
        
        // 获取大圆x2和y2
        let x2 = bigCenter.x
        let y2 = bigCenter.y
        
        // 获取圆心距离
        let distance = distanceWith(smallCenter: smallCenter, bigCenter: bigCenter)
        
        // sinθ
        let sinθ = (x2 - x1) / distance
        
        // cosθ
        let cosθ = (y2 - y1) / distance
        
        let r1 = smallRadius
        
        let r2 = bigRadius
        
        // A点
        let pointA = CGPointMake(x1 - r1 * cosθ, y1 + r1 * sinθ)
        // B点
        let pointB = CGPointMake(x1 + r1 * cosθ, y1 - r1 * sinθ)
        // C点
        let pointC = CGPointMake(x2 + r2 * cosθ, y2 - r2 * sinθ)
        // D点
        let pointD = CGPointMake(x2 - r2 * cosθ, y2 + r2 * sinθ)
        
        // 控制点
        // O点
        let pointO = CGPointMake(pointA.x + distance * 0.5 * sinθ, pointA.y + distance * 0.5 * cosθ)
        // P点
        let pointP = CGPointMake(pointB.x + distance * 0.5 * sinθ, pointB.y + distance * 0.5 * cosθ)
        
        // 描述路径
        let path = UIBezierPath()
        
        path.moveToPoint(pointA)
        
        path.addLineToPoint(pointB)
            
        path.addQuadCurveToPoint(pointC, controlPoint: pointP)

        path.addLineToPoint(pointD)

        path.addQuadCurveToPoint(pointA, controlPoint: pointO)
            
        return path
    
    }
    
    //还原
    private func setUpReset(){
        
        shapeLayer.removeFromSuperlayer()
        
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
            
                self.center = self.originalCenter
            
            }) { (b) -> Void in
                
                self.isOverBorder = false
                
                self.smallCircleView.hidden = false
        }
        
    }
    
    //爆炸效果
    private func setUpBoom(){
        
        //变成气泡消失
        let imageView = UIImageView()
        
        imageView.frame = CGRectMake(0, 0, originalR * 2, originalR * 2)
        
        addSubview(imageView)
        
        var arr:[UIImage] = Array()
        
        let path:NSString = "WXBubbleButton.bundle"

        for i in 1..<9{
            
//            print(path.stringByAppendingPathComponent("\(i)")+".jpg")
            
            let image = UIImage(named: path.stringByAppendingPathComponent("\(i)").stringByAppendingString(".jpg"))
            
//            let image = UIImage(named: "WXBubbleButton.bundle/1.jpg")
            
            arr.append(image!)
            
        }
        
        imageView.animationImages = arr
        
        imageView.animationDuration = 1.2
        
        imageView.animationRepeatCount = 1
        
        imageView.startAnimating()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
            
            imageView.removeFromSuperview()
            
            self.removeFromSuperview()
            
        }
        
    }
    
    private func distanceWith(smallCenter smallCenter: CGPoint, bigCenter: CGPoint)->CGFloat{
     
        let distanceX = bigCenter.x - smallCenter.x
        
        let distanceY = bigCenter.y - smallCenter.y
        
        let distance = sqrt((distanceX * distanceX) + (distanceY * distanceY))
        
        return distance
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        //设置变量
        originalCenter = center
        
        originalR = bounds.size.width * 0.5
        
        layer.cornerRadius = originalR
        
        layer.masksToBounds = true
        
    }

}