# HappyPug
Happy pug is a mobile application created to give transparency in dog food products. Simply scan the 
ingredient list of any dog food product and  the results provides the user with a detailed description 
and rating of each ingredient found in their dog food product. The user is also supplied with a pie chart 
analysis that shows the percentage of ingredients in a given category. In addition, an overall rating is 
determined by inspection of each ingredient rating and first five ingredients found.

## Implementation
Happy Pug relies on the firebase database, which is where the ingredient information is stored. Ingredient 
infromation is reserached from the AAFCO and Tailblazers Pets website to ensure accuracy of each rating and
description. Happy pug uses text recognition to scan the ingredient list and calls the database to find any
simliar ingredients. The filitering function uses string manipulation to ensure that the scanned ingredients 
and the ingredients from the databse are in the same format since comparison is case sensitive. If any similar
ingredients are found, then the results are displayed on the next screen. The overall rating system works out
of a 100, so each ingredient a certain amount of points calculated by 100 divided by the number of ingredients 
found. If a ingredient has a green rating, than it adds full points, if an ingredient is yellow, than it adds
half-points, if an ingredient is read than it adds no points. Additional bonus points are added if the first
five ingredients are green, than add another full pints and if there contains a yellow in the first five, than 
subtract another half-points and if there contains a red than subtract another full points.

## Technologies
## Setup

**Sample Output**
