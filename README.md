# HealthSurvey

I use this app as an experiment to get insights into my health over time. Currently the app consists of two surveys build upon Apple ResearchKit.

The morning survey asks questions about:
  * Mood
  * Stress level
  * Sleep (based upon information from the Sense app by Hello)
  * Weight and body fat percentage

The evening survey asks questions about:
  * Mood
  * Stress level
  * Alcohol intake
  * Activity (steps, workout)
  * Blood pressure and heart rate
  
The surveys are transmitted to a local CouchDB instance. No graphs are yet been used for displaying the data. 

Please note that Apple ResearchKit (opensource) is needed for this project.

## Todo
  * Save/retrieve from HealthKit as much as possible
  * Show data from CouchDB in charts
  * Get some cool insights based upon the data (IBM Watson?)
  
  
