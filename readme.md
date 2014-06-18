# Spanish Quiz

Nothing like duolingo. Merely a rapid fire command line quiz game. mostly for practicing conjugating verbs but really it could do anything.

![screenshots](anim.gif)


## Installation
```
git clone git@github.com:captainclam/spanish-conjugation-quiz.git
cd spanish-conjugation-quiz
npm install
npm start
```

## Usage

You will be prompted to choose what you want to study. Currently there's only 100 verbs, but with 6 prefixes and 5 tenses that's about 3000 conjugations to practice.

Type `exit` to quit the program.


## Updating the dictionary

Edit the file `verbs`, and add to the list of verbs (in their infinitive form).

Run `fetch.coffee` and pipe the output to the dictionary (e.g. `coffee fetch.coffee >> data`).

Note if you get some bad/empty responses from spanishdict.com you may need to run the command again. It will only add new entries to the dictionary for verbs that have not already been fetched, so there is no harm in running it multiple times.


## TODO / Ideas

- Conjugation tables using cli-table for hints
- Highlight irregular verbs
- Have the english translation of the infinitive
