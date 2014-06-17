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

You will be prompted to choose what you want to study. Currently there's only 20 verbs, but with 6 prefixes and 5 tenses that's about 600 conjugations to practice.

Type `exit` to quit the program.


## Updating the dictionary

Edit fetch.coffee, and chance the list of verbs (in their infinitive form) on line 10. Run that file and pipe the output to the dictionary (e.g. `coffee fetch.coffee > data`). Note if you get some bad responses from spanishdict.com you can get crap in the dictionary file which will ruin the program. just open it in a text edit and skim it looking for entries that failed and remove them.
