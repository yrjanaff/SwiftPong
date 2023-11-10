//
//  ViewController.swift
//  pong
//
//  Created by Yrjan on 10/11/2023.
//

import UIKit

class ViewController: UIViewController {
    
    var ballView: UIView!
    var playerPaddleView: UIView!
    var aiPaddleView: UIView!
    var gameTimer: Timer?
    var ballVelocity = CGPoint(x: 10, y: 10)
    var speedFactor: CGFloat = 0.5
    
    var playerScoreLabel: UILabel!
    var aiScoreLabel: UILabel!
    var playerScore = 0
    var aiScore = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayingField()
        setupScoreLabels()
        setupBall()
        setupPaddles()
        randomizeBallDirection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionPaddles()
    }
    
    func setupPlayingField() {
        // Background
        view.backgroundColor = .black
        
        // Divider
        let stripeWidth: CGFloat = 5
        let stripeHeight: CGFloat = 20
        let gapHeight: CGFloat = 15
        let totalStripes = Int((view.bounds.height / (stripeHeight + gapHeight)).rounded())

        for i in 0..<totalStripes {
            let stripe = UIView(frame: CGRect(x: (view.bounds.width / 2) - (stripeWidth / 2),
                                              y: CGFloat(i) * (stripeHeight + gapHeight),
                                              width: stripeWidth,
                                              height: stripeHeight))
            stripe.backgroundColor = .white
            view.addSubview(stripe)
        }
    }
    
    func setupScoreLabels() {
        playerScoreLabel = UILabel()
        aiScoreLabel = UILabel()

        let labelWidth: CGFloat = 100
        let labelHeight: CGFloat = 80
        let topMargin: CGFloat = 20

        playerScoreLabel.frame = CGRect(x: (view.bounds.width / 2) - labelWidth - 20, y: topMargin, width: labelWidth, height: labelHeight)
        aiScoreLabel.frame = CGRect(x: (view.bounds.width / 2) + 20, y: topMargin, width: labelWidth, height: labelHeight)

        [playerScoreLabel, aiScoreLabel].forEach {
            $0.font = UIFont(name: "SquareFont", size: 90)
            // $0.font = UIFont.systemFont(ofSize: 60, weight: .bold)
            $0.textColor = .white
            $0.textAlignment = .center
            $0.text = "0"
            view.addSubview($0)
        }
    }

    func setupBall() {
        // Set up the ball
        ballView = UIView(frame: CGRect(x: view.center.x - 10, y: view.center.y - 10, width: 20, height: 20))
        ballView.backgroundColor = .red
        ballView.layer.cornerRadius = 10
        view.addSubview(ballView)
    }

    func setupPaddles() {
        // Initialize the player paddle on the left
        playerPaddleView = UIView()
        playerPaddleView.backgroundColor = .blue
        view.addSubview(playerPaddleView)
        
        // Initialize the AI paddle on the right
        aiPaddleView = UIView()
        aiPaddleView.backgroundColor = .green
        view.addSubview(aiPaddleView)
    }

    func positionPaddles() {
        // Position the player paddle on the left, accounting for the safe area
        let playerPaddleY = view.center.y - 30
        playerPaddleView.frame = CGRect(x: view.safeAreaInsets.left + 10, y: playerPaddleY, width: 10, height: 60)
        
        // Position the AI paddle on the right, accounting for the safe area
        let aiPaddleY = view.center.y - 30
        aiPaddleView.frame = CGRect(x: view.bounds.width - view.safeAreaInsets.right - 20, y: aiPaddleY, width: 10, height: 60)
    }


    func randomizeBallDirection() {
        let angleDegrees = Double.random(in: 30...60)
        let angleRadians = angleDegrees * .pi / 180
        let horizontalSpeed: CGFloat = 10
        let verticalSpeed = horizontalSpeed * tan(CGFloat(angleRadians))
        
        // Randomly choose to launch the ball left or right
        let horizontalDirection = (Bool.random() ? horizontalSpeed : -horizontalSpeed) * speedFactor
        let verticalDirection = (Bool.random() ? verticalSpeed : -verticalSpeed) * speedFactor

        ballVelocity = CGPoint(x: horizontalDirection, y: verticalDirection)
    }


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: view)
            let newY = max(view.safeAreaInsets.top, min(touchLocation.y, view.bounds.height - view.safeAreaInsets.bottom - playerPaddleView.frame.height / 2))
            playerPaddleView.center.y = newY
        }
    }
    
    func updateScores(playerPoint: Bool) {
        playerScore = playerPoint ? playerScore + 1 : playerScore
        aiScore = playerPoint ? aiScore : aiScore + 1
        playerScoreLabel.text = "\(playerScore)"
        aiScoreLabel.text = "\(aiScore)"
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            self?.moveBall()
            self?.moveAIPaddle()
        }
    }

    func moveBall() {
        ballView.center = CGPoint(x: ballView.center.x + ballVelocity.x, y: ballView.center.y + ballVelocity.y)

        // Bounce off the top and bottom edges
        if ballView.frame.minY < view.safeAreaInsets.top || ballView.frame.maxY > view.bounds.height - view.safeAreaInsets.bottom {
            ballVelocity.y = -ballVelocity.y
        }

        // Collision detection with paddles
        if ballView.frame.intersects(playerPaddleView.frame) || ballView.frame.intersects(aiPaddleView.frame) {
            ballVelocity.x = -ballVelocity.x
        }
        

        // Reset game if the ball goes off the left or right edges
        if ballView.frame.minX < view.safeAreaInsets.left {
            updateScores(playerPoint: false)
            resetGame()
        }
        
        if ballView.frame.maxX > view.bounds.width - view.safeAreaInsets.right {
            updateScores(playerPoint: true)
            resetGame()
        }
    }

    func moveAIPaddle() {
        let middleOfPaddle = aiPaddleView.frame.height / 2
        let targetY = ballView.center.y
        let newY = max(view.safeAreaInsets.top, min(targetY, view.bounds.height - view.safeAreaInsets.bottom - aiPaddleView.frame.height / 2))
        
        if newY < aiPaddleView.center.y - middleOfPaddle {
            aiPaddleView.center.y -= 5
        } else if newY > aiPaddleView.center.y + middleOfPaddle {
            aiPaddleView.center.y += 5
        }
    }

    func resetGame() {
        ballView.center = CGPoint(x: view.center.x, y: view.center.y)
        randomizeBallDirection()
    }
}
