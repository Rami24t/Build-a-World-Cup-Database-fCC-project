#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#  
# Create 'worldcup' database structure according to the provided user stories
#
# CREATE TABLE teams(team_id SERIAL PRIMARY KEY, name VARCHAR(20) UNIQUE NOT NULL);
# CREATE TABLE games(game_id SERIAL PRIMARY KEY, year INT NOT NULL, round VARCHAR(20) NOT NULL,
# winner_id INT REFERENCES teams(team_id) NOT NULL, opponent_id INT REFERENCES teams(team_id) NOT NULL,
# winner_goals INT NOT NULL, opponent_goals INT NOT NULL);
#
# Clear stored data; Empty the rows in the tables of the database
echo "$($PSQL "TRUNCATE games, teams;")"

# Read and store data properly from the games.csv file into the database
cat games.csv | while IFS=(',') read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
# Add the winner team to the teams table if not inserted already
do
if [[ $YEAR != 'year' ]]
then
# Check if not inserted already
if [[ -z "$($PSQL "SELECT * FROM teams WHERE name='$WINNER';")" ]]
then
# Insert new team into the teams table
INSERT_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")"
if [[ $INSERT_RESULT=="INSERT 0 1" ]]
then
echo "Inserted into teams, team $WINNER"
fi
fi
# Add the opponent team to the teams table if not inserted already
# check if not inserted already
if [[ -z "$($PSQL "SELECT * FROM teams WHERE name='$OPPONENT';")" ]]
then
# Insert new team into the teams table
INSERT_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")"
if [[ $INSERT_RESULT=="INSERT 0 1" ]]
then
echo "Inserted into teams, team $OPPONENT"
fi
fi
# insert game
INSERT_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', (SELECT team_id from teams WHERE name='$WINNER'), (SELECT team_id FROM teams WHERE name='$OPPONENT'), $WINNER_GOALS, $OPPONENT_GOALS);")"
if [[ INSERT_RESULT=="INSERT 0 1" ]]
then
echo "Inserted into games, $YEAR-$ROUND: $WINNER-$OPPONENT $WINNER_GOALS-$OPPONENT_GOALS"
fi
fi
done
