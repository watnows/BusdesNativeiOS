struct BusStopModel: Hashable {
    let name: String
    let kana: String
}

extension BusStopModel {
    static let dataList: [BusStopModel] = [
        BusStopModel(name: "立命館大学", kana: "りつめいかんだいがく"),
        BusStopModel(name: "南草津駅", kana: "みなみくさつえき"),
        BusStopModel(name: "野路", kana: "のじ"),
        BusStopModel(name: "南田山", kana: "なんだやま"),
        BusStopModel(name: "玉川小学校前", kana: "たまがわしょうがっこうまえ"),
        BusStopModel(name: "小野山", kana: "おのやま"),
        BusStopModel(name: "パナソニック東口", kana: "ぱなそにっくひがしぐち"),
        BusStopModel(name: "パナソニック前", kana: "ぱなそにっくまえ"),
        BusStopModel(name: "パナソニック西口", kana: "ぱなそにっくにしぐち"),
        BusStopModel(name: "笠山東", kana: "かさやまひがし"),
        BusStopModel(name: "笹の口", kana: "ささのぐち"),
        BusStopModel(name: "クレスト草津前", kana: "くれすとくさつまえ"),
        BusStopModel(name: "BKCグリーンフィールド", kana: "びーけーしーぐりーんふぃーるど"),
        BusStopModel(name: "野路北口", kana: "のじきたぐち"),
        BusStopModel(name: "草津クレアホール", kana: "くさつくれあほーる"),
        BusStopModel(name: "東矢倉南", kana: "ひがしやくらみなみ"),
        BusStopModel(name: "東矢倉職員住宅", kana: "ひがしやくらしょくいんじゅうたく"),
        BusStopModel(name: "向山ニュータウン", kana: "むこうやまにゅーたうん"),
        BusStopModel(name: "丸尾", kana: "まるお"),
        BusStopModel(name: "若草北口", kana: "わかくさきたぐち"),
        BusStopModel(name: "立命館大学正門前", kana: "りつめいかんだいがくしょうもんまえ")
    ]
}
