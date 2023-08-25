#! /bin/bash

# creacion tablas
# create table teams(team_id serial primary key, neme varchar(15) unique not null);
# create table games(game_id serial primary key, year int not null, round varchar(15) not null, winner_id int not null references teams(team_id), opponent_id int not null references teams(team_id), winner_goals int not null, opponent_goals int not null);

if [[ $1 == "test" ]]
then 
    PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
    PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "truncate teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINGOAL OPPGOAL
do
    if [[ $YEAR != "year" ]]
    then
        # get winner_id
        WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")

        # if not found
        if [[ -z $WINNER_ID ]]
        then
            # insert team
            INSERT_TEAM_RESULT=$($PSQL "insert into teams(name) values('$WINNER')")
            
            if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
            then
                echo Inserted into teams, $WINNER
            fi
        fi

        # get new winner_id
        WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")

        # get opponent_id
        OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")

        if [[ -z $OPPONENT_ID ]]
        then
            # insert team
            INSERT_TEAM_RESULT=$($PSQL "insert into teams(name) values('$OPPONENT')")
            
            if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
            then
                echo Inserted into teams, $WINNER
            fi
        fi

        # get new opponent_id
        OPPONENT_ID=$($PSQL "select team_id from teams where name='$WINNER'")

        # insert games
        INSERT_GAMES_RESULT=$($PSQL "insert into games
        (year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
        values
        ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINGOAL, $OPPGOAL)")
        
        if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
        then
            echo Inserted into games, $WINNER $WINGOAL - $OPPGOAL $OPPONENT
        fi
    fi
done
