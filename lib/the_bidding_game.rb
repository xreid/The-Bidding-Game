#!/bin/ruby

# constants
INITIAL_BALANCE = 100
INITIAL_BID     = 11
BOARD_LENGTH    = 10

def calculate_bid(player, pos, first_moves, second_moves)
  return INITIAL_BID if first_moves.empty?
  opponent                  = player == 1 ? 2 : 1
  opponent_moves            = player == 1 ? second_moves : first_moves
  moves                     = player == 1 ? first_moves : second_moves
  balance, opponent_balance = sum_balances(player, first_moves, second_moves)
  return 0 if balance == 0
  return 1 if opponent_balance == 0
  distance          = find_distance(player, pos)
  opponent_distance = BOARD_LENGTH - distance
  bid               = 1
  if distance > 2 && distance < 8
    if moves[-1] > opponent_moves[-1] && moves[-1] < 15
      bid = opponent_moves[-1] + 1
    end
  elsif distance <= 1 # attempt to secure win
    bid = [balance / distance, opponent_balance / distance].min
    bid += 1 if bid == opponent_balance / distance && bid + 1 <= balance
  elsif distance >= 9 # attempt to prevent loss
    bid = [balance / opponent_distance,
      opponent_balance / opponent_distance].min
    bid += 1 if bid == opponent_balance / opponent_distance && bid + 1 <= balance
  end
  bid = [balance / opponent_distance,
    opponent_balance / opponent_distance].min if bid == 1
  bid = (bid / 2) + 1 if bid >= 15 && distance > 1 && distance < 9
  bid = 12 if bid > 12 && moves.size < 4
  return bid unless bid < 1 || bid > balance
  1 # if all else fails, return 1
end

# returns the balance for the given player
def sum_balances(player, first_moves, second_moves)
  balance1       = INITIAL_BALANCE
  balance2       = INITIAL_BALANCE
  draw_advantage = true # true when player 1 has draw_advantage advantage

  first_moves.each_with_index do |bid1, index|
    bid2 = second_moves[index]
    if bid1 == bid2 # draw
      balance1 -= bid1 if draw_advantage
      balance2 -= bid2 unless draw_advantage
      draw_advantage = !draw_advantage
    else
      winning_bid = [bid1, bid2].max
      # deduct winning bids form corresponding balance
      balance1 -= winning_bid if winning_bid == bid1
      balance2 -= winning_bid if winning_bid == bid2
    end
  end
  player == 1 ? [balance1, balance2] : [balance2, balance1]
end

# returns the distance from player to scotch
def find_distance(player, pos)
  player == 1 ? pos : BOARD_LENGTH - pos
end

# script

# gets the id of the player
player = gets.to_i
# current position of the scotch
scotch_pos = gets.to_i

# convert from string to int
first_moves  = gets.split.map(&:to_i)
second_moves = gets.split.map(&:to_i)

bid = calculate_bid(player, scotch_pos, first_moves, second_moves)
puts bid
