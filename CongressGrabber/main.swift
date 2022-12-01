import Foundation

struct Legislator {
    let name: String
    let state: String
    let party: String
    let vote: String
}

class XMLParserDelegateImpl: NSObject, XMLParserDelegate {
    
    var dict: [String: String] = [:]
    var curElement: String = "first"
    
    var curLegislatorName = ""
    var curLegislatorState = ""
    var curLegislatorParty = ""
    var curLegislatorVote = ""
    
    var legislators: [Legislator] = []
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:])
    {
        if elementName == "legislator" || elementName == "vote" || elementName == "recorded-vote" {
            curElement = elementName
        }
        if elementName == "legislator" {
            curLegislatorState = attributeDict["state"]!
            curLegislatorParty = attributeDict["party"]!
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if curElement == "legislator" {
            curLegislatorName = string
        } else if curElement == "vote" {
            curLegislatorVote = string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard curElement == "vote" else {
            return
        }
        let legislator = Legislator(name: curLegislatorName,
                                    state: curLegislatorState,
                                    party: curLegislatorParty,
                                    vote: curLegislatorVote)
        legislators.append(legislator)
        print("\(legislator.name) (\(legislator.party)-\(legislator.state)): \(legislator.vote)")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print(legislators.count)
    }
}


let url = URL(string: "https://clerk.house.gov/evs/2022/roll490.xml")!
let request = URLRequest(url: url)
let parserDelegate = XMLParserDelegateImpl()

URLSession.shared.dataTask(with: request) { data, response, error in
    let parser = XMLParser(data: data!)
    parser.delegate = parserDelegate
    parser.parse()
}.resume()

RunLoop.main.run()
