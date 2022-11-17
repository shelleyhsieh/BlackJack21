//
//  ViewController.swift
//  BlackJack21
//
//  Created by shelley on 2022/11/2.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var computerCardView: [UIView]!
    @IBOutlet var playerCardView: [UIView]!
    @IBOutlet var rankALable: [UILabel]!
    @IBOutlet var suitALable: [UILabel]!
    @IBOutlet var suitA2Lable: [UILabel]!
    @IBOutlet var suitB2Lable: [UILabel]!
    @IBOutlet var rankBLable: [UILabel]!
    @IBOutlet var suitBLable: [UILabel]!
    @IBOutlet weak var sumACardPointLable: UILabel!
    @IBOutlet weak var sumBCardPointLable: UILabel!
    
    @IBOutlet weak var totatBetMoneyLable: UILabel!
    @IBOutlet weak var remainMoneyLable: UILabel!
    @IBOutlet weak var wordLable: UILabel!
    
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var cards = [Card]()
    var computerCards = [Card]()
    var playerCards = [Card]()
    
    var index = 1
    var cptSum: Int {
        var cptSum = 0
        for i in computerCards{
            cptSum += caculateRankNumber(card: i)
        }
        return cptSum
    }
    var pSum: Int {
        var pSum = 0
        for i in playerCards{
            pSum += caculateRankNumber(card: i)
        }
        return pSum
    }
    var takeACard = Int.random(in: 0...51)
    var ownMoney = 2000
    var betMoney = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
// 生成52張卡牌
        for rank in ranks {
            for suit in suits {
                let card = Card()
                card.rank = rank
                card.suit = suit
                cards.append(card)
            }
        }
        gameStar()
// 卡牌加入邊框顏色，邊的粗細，圓弧，底色
        for i in 0...4 {
            computerCardView[i].layer.borderWidth = 0.5
            computerCardView[i].layer.borderColor = UIColor.black.cgColor
            computerCardView[i].backgroundColor = UIColor.white
            computerCardView[i].layer.cornerRadius = 10
            playerCardView[i].layer.borderWidth = 0.5
            playerCardView[i].layer.borderColor = UIColor.black.cgColor
            playerCardView[i].backgroundColor = UIColor.white
            playerCardView[i].layer.cornerRadius = 10
        }
    }
// 遊戲初始
    func gameStar(){
        computerCards = [Card]()
        playerCards = [Card]()
        index = 1
        totatBetMoneyLable.text = "\(betMoney)"
        remainMoneyLable.text = "\(ownMoney)"
        wordLable.text = "遊戲開始，請開始下注！"
//  顯示兩張牌並計算牌面點數，剩下三張不顯示
        for i in 0...4 {
            if i < 2 {
                computerCardView[i].isHidden = false
                playerCardView[i].isHidden = false
                cards.shuffle()
                computerCards.append(cards[i])
                cards.shuffle()
                playerCards.append(cards[i])
                rankALable[i].text = computerCards[i].rank
                suitALable[i].text = computerCards[i].suit
                suitA2Lable[i].text = computerCards[i].suit
                rankBLable[i].text = playerCards[i].rank
                suitBLable[i].text = playerCards[i].suit
                suitB2Lable[i].text = playerCards[i].suit
                sumACardPointLable.text = "\(cptSum)"
                sumBCardPointLable.text = "\(pSum)"
            }else{
                computerCardView[i].isHidden = true
                playerCardView[i].isHidden = true
            }
        }
    }
// 牌面點數計算
    func caculateRankNumber(card:Card) -> Int {
        var cardRankNumber = 0
        switch card.rank{
        case "A":
            cardRankNumber = 1
        case "J","Q","K":
            cardRankNumber = 10
        default:
            cardRankNumber = Int(card.rank)!
        }
        return cardRankNumber
        }
// 按鈕決定賭金，籌碼總額為2000，加減籌碼一次100，籌碼歸零即遊戲結束
    @IBAction func betMoneyControl(_ sender: UIButton) {
        if sender == addButton {
            if ownMoney >= 100{
                betMoney += 100
                ownMoney -= 100
            }
        }else if betMoney >= 100{
            betMoney -= 100
            ownMoney += 100
        }
// 賭金不為負數
        if betMoney < 0{
            betMoney = 0
// 當籌碼歸零時，遊戲重新開始，籌碼為2000
        }else if ownMoney < 0{
            ownMoney = 0
            gameStar()
        }
        remainMoneyLable.text = "\(ownMoney)"
        totatBetMoneyLable.text = "\(betMoney)"
    }
// 玩家要牌，要牌前須先下注
    @IBAction func Hit(_ sender: UIButton) {
        if checkBetMoney() == true {
// 隨機抽牌，一次加一張牌
            takeACard = Int.random(in: 0...51)
            index = index + 1
            playerCardView[index].isHidden = false
            playerCards.append(cards[index])
            cards.shuffle()
            rankBLable[index].text = playerCards[index].rank
            suitBLable[index].text = playerCards[index].suit
            suitB2Lable[index].text = playerCards[index].suit
            sumBCardPointLable.text = "\(pSum)"
        }
// 當卡牌為5張且＜21點，過五關！獎金2倍；=21,贏回賭金；>21，輸掉賭金
        if index == 4 , pSum <= 21{
            gameAlert(title: "過五關！", message: "贏回賭金啦！")
            ownMoney += betMoney * 2
            remainMoneyLable.text = "\(ownMoney)"
            betMoney -= betMoney
            totatBetMoneyLable.text = "\(betMoney)"
        }else if pSum == 21 {
            gameAlert(title: "恭喜！", message: "21點獲勝!")
            ownMoney = ownMoney + betMoney + betMoney
            remainMoneyLable.text = "\(ownMoney)"
            betMoney -= betMoney
            totatBetMoneyLable.text = "\(betMoney)"
        }else if pSum > 21 {
            ownMoney = ownMoney + betMoney - betMoney
// 確認賭金是否<0，有籌碼可繼續玩，沒有籌碼則遊戲結束
            if checkOwnMoney() == false {
                gameAlert(title: "OOPS!", message: "爆掉了，\(pSum)小於\(cptSum)")
                remainMoneyLable.text = "\(ownMoney)"
                betMoney -= betMoney
                totatBetMoneyLable.text = "\(betMoney)"
            }else{
                gameAlert(title: "OH NOOO", message: "GAME OVER!賭金歸零")
                betMoney = 0
                ownMoney = 2000
            }
        }
    }
// 開牌，閒家認為點數夠了可選擇停牌，點數即固定
    @IBAction func stand(_ sender: UIButton) {
        if checkBetMoney() == true {
// 當電腦牌面點數<=17，繼續抽牌
            if cptSum <= 17{
// 當電腦牌面點數<=21繼續抽牌，且莊家<玩家時，繼續補牌最多5張
                for i in 2...4{
                    if cptSum <= 21, cptSum < pSum {
                        takeACard = Int.random(in: 0...51)
                        computerCardView[i].isHidden = false
                        computerCards.append(cards[takeACard])
                        rankALable[i].text = computerCards[i].rank
                        suitALable[i].text = computerCards[i].suit
                        suitA2Lable[i].text = computerCards[i].suit
                        sumACardPointLable.text = "\(cptSum)"
                        if cptSum == 21{
                            ownMoney = ownMoney + betMoney - betMoney
                            betMoney -= betMoney
                            if checkOwnMoney() == false{
                                gameAlert(title: "BlackJack!", message: "電腦獲勝！")
                                remainMoneyLable.text = "\(ownMoney)"
                                totatBetMoneyLable.text = "\(betMoney)"
                            }else{
                                gameAlert(title: "OHNO,賭金歸零", message: "遊戲重新開始")
                                betMoney = 0
                                ownMoney = 2000
                            }
                        }else if cptSum > 21{
                            ownMoney += betMoney
                            betMoney -= betMoney
                            gameAlert(title: "OH YEAH!", message: "電腦爆啦")
                            remainMoneyLable.text = "\(ownMoney)"
                            totatBetMoneyLable.text = "\(betMoney)"
                        }else if i == 4 && cptSum <= 21{
                            ownMoney = ownMoney + betMoney - betMoney
                            betMoney -= betMoney
                            if checkOwnMoney() == false{
                                gameAlert(title: "哎呀～", message: "電腦過五關")
                                remainMoneyLable.text = "\(ownMoney)"
                                totatBetMoneyLable.text = "\(betMoney)"
                            }else{
                                gameAlert(title: "OHNO,賭金歸零", message: "遊戲重新開始")
                                betMoney = 0
                                ownMoney = 2000
                            }
                        }
                    }
                }
            }else{
                if cptSum < pSum {
                    ownMoney = ownMoney + betMoney + betMoney
                    betMoney -= betMoney
                    gameAlert(title: "恭喜！", message: "\(pSum)大於\(cptSum)")
                    remainMoneyLable.text = "\(ownMoney)"
                    totatBetMoneyLable.text = "\(betMoney)"
                }else if cptSum > pSum {
                    ownMoney = ownMoney + betMoney - betMoney
                    betMoney -= betMoney
                    remainMoneyLable.text = "\(ownMoney)"
                    totatBetMoneyLable.text = "\(betMoney)"
                    if checkOwnMoney() == false {
                        gameAlert(title: "玩家輸了", message: "\(cptSum)大於\(pSum)")
                    }else{
                        gameAlert(title: "OHNO,賭金歸零", message: "遊戲重新開始")
                        ownMoney = 2000
                    }
                }else{
                    gameAlert(title: "平手", message: "下一局")
                    ownMoney = ownMoney + betMoney
                    betMoney -= betMoney
                }
            }
            if betMoney == 0, ownMoney == 0 {
                gameStar()
            }
        }
    }
// 棄牌時，賭金只能回收一半，重新發牌
    @IBAction func surrender(_ sender: UIButton) {
        ownMoney += betMoney / 2
        remainMoneyLable.text = "\(ownMoney)"
        wordLable.text = "棄牌"
        totatBetMoneyLable.text = "\(0)"
        gameStar()
    }
    
        func gameAlert(title: String, message: String){
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "再玩一次！", style: .default) { okAction in
                self.gameStar()
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        func betMoneyAlert(title: String, message: String){
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { okAction in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
// 確認賭金
        func checkBetMoney() -> Bool?{
            if betMoney <= 0{
                betMoneyAlert(title: "提醒！", message: "尚未下注賭金")
                totatBetMoneyLable.text = "\(0)"
                return false
            }else{
                return true
            }
        }
// 確認玩家籌碼餘額
       func checkOwnMoney() -> Bool?{
            if ownMoney <= 0{
                return true
            }else{
                return false
            }
        }
}
