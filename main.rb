require 'discordrb'require 'nokogiri'
require 'open-uri'
require 'dotenv'
Dotenv.load '.env.token'
Dotenv.load '.env.client'

bot = Discordrb::Commands::CommandBot.new token: ENV['token'],
                                          client_id: ENV['client_id'],
                                          prefix: '/'

class Player
  def setName(str)
    @name = str
  end
  def putName
    return @name
  end
  def playCreature(str)
    @creatures << str
  end
  def putCreatures
    return @creatures
  end
  def destroyCreature(int)
    @creatures.delete_at(int)
  end
  def resetCreatures
    @creatures = []
  end
end

player1 = Player.new
player2 = Player.new

bot.command :momir_find, description: "
'/momir_find 1' でPlayer1の戦場表示.Player2も同様.
'/momir_find me'で自分の戦場表示." do |event, name|

  case name
  when '1'
    event.respond("#{player1.putName} Battlefield: #{player1.putCreatures}")
  when '2'
    event.respond("#{player2.putName} Battlefield: #{player2.putCreatures}")
  when 'me'
    event.respond("#{event.user.name} Battlefield: #{player1.putCreatures}") if "#{event.user.name}" == player1.putName
    event.respond("#{event.user.name} Battlefield: #{player2.putCreatures}") if "#{event.user.name}" == player2.putName
  end
end

bot.command :momir_destroy, description: "
'/momir_destroy 1 0'でPlayer1の一番目のクリーチャーを消す.Player2も同様
'/momir_destroy 1 all'でPlayer1の全てのクリーチャーを消す.Player2も同様
'momir_destroy me 0'で自分の一番目のクリーチャーを消す.'" do |event, playerNum, target|
  case playerNum
  when '1'
    if target != 'all'
      event.respond("destroy: #{player1.destroyCreature(target.to_i)}")
      event.respond("#{player1.putName} Battlefield: #{player1.putCreatures}")
    else
      event.respond("destroy all creatures")
      player1.resetCreatures
    end
  when '2'
    if target != 'all'
      event.respond("destroy: #{player2.destroyCreature(target.to_i)}")
      event.respond("#{player2.putName} Battlefield: #{player2.putCreatures}")
    else
      event.respond("destroy all creatures")
      player2.resetCreatures
    end
  when 'me'
    if "#{event.user.name}" == player1.putName
      if target != 'all'
        event.respond("destroy: #{player1.destroyCreature(target.to_i)}")
        event.respond("#{player1.putName} Battlefield: #{player1.putCreatures}")
      else
        event.respond("destroy all creatures")
        player1.resetCreatures
      end
    end
    if "#{event.user.name}" == player2.putName
      if target != 'all'
        event.respond("destroy: #{player2.destroyCreature(target.to_i)}")
        event.respond("#{player2.putName} Battlefield: #{player2.putCreatures}")
      else
        event.respond("destroy all creatures")
        player2.resetCreatures
      end
    end
  end
  
end

bot.command :momir_player, description: "
'/momir_player 1'でPlayer1に発言者の名前が設定される.Player2も同様." do |event, num|
  break if event.channel.name != 'momir_basic'
  case num
  when '1'
    player1.setName("#{event.user.name}")
    player1.resetCreatures
  when '2'
    player2.setName("#{event.user.name}")
    player2.resetCreatures
  end

  if !num.match(/[1-2]/).nil?
    event.respond("Set Player#{num}\nPlayer#{num}: #{event.user.name}")
    event.respond("#{event.user.name} D6(roll...) => #{rand(1..6)}")
  end
end

bot.command :momir_roll, description: "
'/momir_roll'で6面ダイスを1個振る.
" do |event|
  event.respond("#{event.user.name} D6(roll...) => #{rand(1..6)}")
end

bot.command :momir_land, description: "
山, 島, 森, 沼, 平地, 荒地がランダムに出力される.
戦場には残らないのでメモ必須
" do |event|
  land_array = ["Mountain", "Island", "Forest", "Swamp", "Plains", "Wastes"]
  land_number = rand(0..5)
  event.respond("#{event.user.name} play #{land_array[land_number]}")
end

bot.command :momir, description: "
Momir Vig, Simic Visionary Avatar
ヴァンガード
手札 +0/ライフ +4
(Ｘ),カードを１枚捨てる：点数で見たマナ・コストがＸである、無作為に選ばれたクリーチャー・カード１枚のコピーであるトークンを１体戦場に出す。この能力は、あなたがソーサリーを唱えられるときにのみ起動でき、各ターンに１回しか起動できない。

'/momir X'で起動
'/help commandName'でヘルプ

CommandList
'momir_player'
'momir_find'
'momir_destroy'
'momir_land'" do |event, mana|

  break if event.channel.name != 'momir_basic'

  if mana.to_i == 13
    imageURL = 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=414295&type=card'
    cardName = 'Emrakul, the Promised End'
    cardType = 'Legendary Creature — Eldrazi'
    cardText = "  This spell costs (1) less to cast for each card type among cards in your graveyard.
  When you cast this spell, you gain control of target opponent during that player's next turn.
  After that turn, that player takes an extra turn."
    cardPT = '13/13'
    event.respond("#{imageURL}\n#{cardName}\n#{cardType}\n#{cardText}\n#{cardPT}")
    player1.playCreature(cardName) if "#{event.user.name}" == player1.putName
    player2.playCreature(cardName) if "#{event.user.name}" == player2.putName
    break
  end

  if mana.to_i == 16
    imageURL = 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=178018&type=card'
    cardName = 'Draco'
    cardType = 'Artifact Creature — Dragon'
    cardText = "  Domain — This spell costs 2 less to cast for each basic land type among lands you control.
  Flying
  Domain — At the beginning of your upkeep, sacrifice Draco unless you pay 10. This cost is reduced by 2 for each basic land type among lands you control."
    cardPT = '9/9'
    event.respond("#{imageURL}\n#{cardName}\n#{cardType}\n#{cardText}\n#{cardPT}")
    player1.playCreature(cardName) if "#{event.user.name}" == player1.putName
    player2.playCreature(cardName) if "#{event.user.name}" == player2.putName
    break
  end


  if mana.to_i.to_s != mana
    event.respond("Please, mana cost is an integer only")
  else
    pageNumber = 0
    url = 'http://gatherer.wizards.com/Pages/Search/Default.aspx?page=' + pageNumber.to_s + 'action=advanced&type=+[%22Creature%22]&cmc=+=[' + mana + ']'
    html = Nokogiri::HTML(open(url))

    cardSheets = html.css('.termdisplay').text.match(/\(.*\)/).to_s[1..-2].to_i
    if cardSheets == 0
      event.respond("There are no creature of this mana cost!")
      break
    end
    cardSum = rand(0..cardSheets-1)
    cardNumber = cardSum % 100
    pageNumber = (cardSum - cardNumber) / 100

    url = 'http://gatherer.wizards.com/Pages/Search/Default.aspx?page=' + pageNumber.to_s + '&action=advanced&type=+[%22Creature%22]&cmc=+=[' + mana + ']'
    html = Nokogiri::HTML(open(url))

    cardSet = html.search('.cardItem')[cardNumber].css('.rightCol > a > img').to_s
    redo if cardSet.include?("Unglued") or cardSet.include?("Unhinged") or cardSet.include?("Unglued")

    cardInfo = html.search('.cardInfo')[cardNumber]
    cardName = cardInfo.search('.cardTitle').text.strip
    puts cardName
    typeLine = cardInfo.search('.typeLine').text.gsub(/\n/,"")
    cardType = typeLine.match(/.*(?=\()/).to_s.strip
    cardPT = typeLine.match(/\(.*?\)/).to_s[1..-2]
    rulesText = cardInfo.css('.rulesText > p').to_s
    rawSymbols = rulesText.scan(/name=[A-Za-z0-9]*/)
    symbolList = []
    rawSymbols.each do |symbol|
      symbol.sub!(/name=/,"")
      symbol = symbol.sub(/untap/,"Q")
      symbol = symbol.sub(/tap/,"T")
      symbolList << symbol
    end

    cardText = ""

    rulesText.each_line do |text|
      if !text.match(/name=/).nil?
        symbolList.each do |symbol|
          text = text.sub(/<img.*?>/,"(" + symbol + ")")
        end
      end
      cardText << "  " + (text.split(/<.*?>/)).join
    end

    imageURL = html.css('.leftCol > a > img')[cardNumber].attribute('src').value.gsub(/\.\.\/\.\./,"http://gatherer.wizards.com")
    event.respond("#{imageURL}\n#{cardName}\n#{cardType}\n#{cardText}\n#{cardPT}")
    player1.playCreature(cardName) if "#{event.user.name}" == player1.putName
    player2.playCreature(cardName) if "#{event.user.name}" == player2.putName
    break
  end
end

bot.run
