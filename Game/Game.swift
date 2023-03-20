//
//  Game.swift
//  Game
//
//  Created by pierrick viret on 11/03/2023.
//

import Foundation

class Game {
    // Propreties
    var players = [Player]()
    let numberOfPlayerInTheGame = 2
    let numberOfCharacterInTeam = 3

    init() {
        initPlayer()
        fight()
        statistic()
    }

    // Init of the 2 players
    private func initPlayer() {
        let maxPlayer = numberOfPlayerInTheGame - 1
        for index in 0...maxPlayer {

            // ask for player name
            let name = getPlayerName(forPlayer: index + 1)

            // ask for team of 3 characters
            let team = getTeam()

            // create player
            self.players.append(Player(name: name, team: team))
            print("\(name), votre équipe est complète")
        }

        print("\nJeu initialisé, voici les équipes")

        // show the team of the 2 players
        displayPlayersTeam()
    }

    // start fight
    private func fight() {
        // define who began the fight
        whoIsStarted()

        var attacker = players[0]
        var attacked = players[1]

        repeat {
            // select attacking character in attacker player
            print("\n\(attacker.name), vous pouvez attaquer avec:")
            let offensiveCharacter = getAliveCharacter(from: attacker)

            // choose action attack or care if magus selected
            var weaponSpecification: WeaponSpecification = .attack
            if offensiveCharacter.type == "Mage" {
                weaponSpecification = chooseWhichWeaponSpecification()
            }

            switch weaponSpecification {
            case .attack:
                // select a character to be attacking in attacked player
                print("vous pouvez attaquer le personnage de \(attacked.name) suivant:")
                let defensiveCharacter = getAliveCharacter(from: attacked)
                defensiveCharacter.beAttacked(by: offensiveCharacter)

            case .care:
                // select character to care in attacking team
                print("vous pouvez soigner le personnage suivant:")
                let offensiveCharacter = getAliveCharacter(from: attacker)
                offensiveCharacter.beCare()
            }

            // increase statistic of attacker player
            let weaponValue = offensiveCharacter.weapon.value
            attacker.increaseStratistic(with: weaponSpecification, value: weaponValue)

            // change player who attack
            players.swapAt(0, 1)
            attacker = players[0]
            attacked = players[1]

            // fight until player had no character alive
        } while attacker.isAlive()
    }

    // show staistic of the 2 players
    private func statistic() {
        let winner = players[1]
        let looser = players[0]

        print("\n\(winner.name) gagne la partie en \(winner.turn) tours")
        print("il a attaqué \(winner.attackturn) fois, pour une puissance de \(winner.strength)")
        print("il a soigné \(winner.careTurn) fois")
        print("voici son équipe")
        winner.showPlayerTeam()

        print("\n\(looser.name) a perdu")
        print("voici son équipe")
        looser.showPlayerTeam()
    }

    // ask player for character type and charactere name
    // return a array of character selected
    private func getTeam() -> [Character] {
        var team = [Character]()
        let maxCharacter = numberOfCharacterInTeam - 1

        for index in 0...maxCharacter {
            
            // ask player to select a character Type
            let charactereType = getCharacterType(number: index + 1)

            // ask player to write a name
            let charactereName = getCharacterName()

            // create character selected
            switch charactereType {
            case "Guerrier" : team.append(Warrior(name: charactereName))
            case "Nain" : team.append(Dwarf(name: charactereName))
            case "Mage" : team.append(Magus(name: charactereName))
            default: print("erreur ")
            }
            print("vous avez crée \(team[index].name) de type \(team[index].type)\n")
        }
        return team
    }

    // ask player for selected a character type
    // return a character type
    private func getCharacterType(number: Int) -> String {
        // create available character in game
        let characters = [Warrior(), Dwarf(), Magus()]

        // show description of available character
        print("veuillez choisir votre personnage numero \(number)")
        for (index, character) in characters.enumerated() {
            let description = character.getDescription()
            print("\(index + 1). \(description)")
        }

        // get player's choice
        let selection = getNumber(withMax: characters.count) - 1

        // return type selected
        return characters[selection].type
    }

    // ask to the player for the name of the character
    // return name
    private func getCharacterName() -> String {

        // get name
        print("veuillez choisir le nom du personnage")
        let name = readLine() ?? ""

        // check if player write something
        guard name.isEmpty == false else {
            print("erreur de saisie, recommencer")
            return getCharacterName()
        }

        // check if name is not already used
        for storedName in Character.names where storedName == name.lowercased() {
            print("nom déja utilisé")
            return getCharacterName()
        }

        // store name for the next check
        Character.names.append(name.lowercased())

        // return name of character
        return name
    }

    // ask player for his name
    // return name
    private func getPlayerName(forPlayer number: Int) -> String {
        // get player name
        print("\nQuel est votre nom Joueur \(number)")
        let name = readLine() ?? ""

        // check if player write something
        guard name.isEmpty == false else {
            print("erreur de saisie, recommencer")
            return getPlayerName(forPlayer: number)
        }

        // check if name is not already used
        for character in players where character.name.lowercased() == name.lowercased() {
            print("nom déja utilisé, merci de choisir un autre nom")
            return getPlayerName(forPlayer: number)
        }
        // return name of player
        print("\nBonjour \(name)")
        return name
    }

    // choose witch player start
    // and the name is shown on the screen
    private func whoIsStarted() {
        if Bool.random() {
            players.swapAt(0, 1)
        }
        print("\n \(players[0].name) commence le jeu")
    }

    // ask player to chose a character alive in player team
    // return character selected
    private func getAliveCharacter(from player: Player) -> Character {

        // display to player character alive
        player.showPlayerTeamAlive()
        // count the number of character alive
        let number = player.nombreOfCharacterAlive()

        // ask player to chose a character
        print("Sélectionner votre personnage")
        let index = getNumber(withMax: number) - 1

        // show and return character selected
        print("vous avez selectionné \(player.team[index].name), un \(player.team[index].type)\n")
        return player.team[index]
    }

    // ask player to selecte weapon specification
    // return care or attack
    private func chooseWhichWeaponSpecification() -> WeaponSpecification {
        print("""
            quelle arme voulez vous utiliser ?
                1. baguette magique: soigner
                2. épé: attaquer
            """)
        // ask player to chose care or attack
        let choice = getNumber(withMax: 2)
        return WeaponSpecification(rawValue: choice)!
    }

    // check if player give a right number between 1 to number
    // return right number
    private func getNumber(withMax number: Int) -> Int {
        // read player's response. if there is no repsonse, put 0
        let readNumber = Int(readLine() ?? "") ?? 0

        // check if response is right: between 1 and passed number
        // if check is not good, reask player to an other number
        if (readNumber == 0) || (readNumber > number) {
            print("nombre non valide")
            return getNumber(withMax: number)
        }
        return readNumber
    }

    // display players team before the game start
    private func displayPlayersTeam() {
        let maxPlayers = numberOfPlayerInTheGame - 1

        for index in 0...maxPlayers {
            print("\n\(players[index].name), votre équipe est composée de:")
            players[index].showPlayerTeam()
            if index != maxPlayers {
                print("\ncontre")
            }
        }
    }
}
