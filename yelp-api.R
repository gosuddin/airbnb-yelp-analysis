require(httr)
require(httpuv)
require(jsonlite)

### USE YOUR CREDENTIALS ####
consumerKey = "YOUR CONSUMER KEY"
consumerSecret = "YOUR CONSUMER SECRET"
token = "YOUR TOKEN"
token_secret = "YOUR TOKEN SECRET"

### AUTHENTICATE YOUR R SESSIONS #####
myapp <- oauth_app("YELP", key=consumerKey, secret=consumerSecret)
sig <- sign_oauth1.0(myapp, token=token, token_secret=token_secret)

### STATIC PART OF THE URL #####
apiurl <- "https://api.yelp.com/v2/search?" 


#### API ####
# TO USE THE API CALL: CALL THE FUNCTION WITH THE TERM YOU WANT TO SEARCH FOR EXAMPLE : "food" or "nightlife".
# The location is hardcoded. 
# offset parameter needs to be changed based on the results retrieved
searchbylocation <- function(term,location = "Seattle",limit=20,offset=0){
  
  ##CREATE DYNAMIC URL ###
  fetch_url <- paste0(apiurl,"term=",term,"&location=",location,"&limit=",limit,"&offset=", offset)
  
  ##PULL DATA##
  results <- GET(fetch_url,sig)
  
  ##CONVERT : HTTP HEADER RESPONSE CONTENT => LIST => JSON => LIST => DATA FRAME
  results <- (as.data.frame(fromJSON(toJSON(content(results)))))
 
  #COlumns of Interest 
  attach(r)
  results <- data.frame(cbind(businesses.id,
                        businesses.name,
                        businesses.categories,
                        businesses.review_count,
                        businesses.rating,
                        businesses.menu_date_updated))
  detach(r)
  
  #Columns of Interests in location
  attach(r$businesses.location)
  locations <- data.frame(cbind(address,
                               neighborhoods,
                               postal_code,
                               coordinate$latitude,
                               coordinate$longitude))
  
  detach(r$businesses.location)
  
  #flatening the dataframes
  results <- data.frame(lapply(results, as.character), stringsAsFactors=FALSE)
  locations <- data.frame(lapply(locations, as.character), stringsAsFactors=FALSE)
  
  #merging the dataframes
  results <- data.frame(results,locations)
  
  #assigning the colnames
  colheads <- c("id","name","category","review_count","rating","menu_data_updated",
                "address","neighborhood","zip","latitude","longitude")
  
  colnames(results) <- colheads
  
  #define file
  file <-NULL
  
  #define filename w.r.t term used
  filename <- paste0(term,"_amenities.csv")
  
  #check if exists. If Yes read the file
  if (file.exists(filename)){
    file<- read.csv(filename)
  }
  
  #merge new rows into existing
  file<- rbind(file,results)
  
  #write the CSV
  write.csv(file,file=filename,row.names=FALSE)
}

