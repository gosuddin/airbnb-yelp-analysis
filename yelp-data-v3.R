# The intention of using v3 of the API is to extract the pricing feature('$', '$$' ,'$$$','$$$$')


#load the libraries
require(httr)
require(httpuv)
require(jsonlite)

#Authenticate on v3 using OAuth 2.0 authentication method
v3Auth <- POST("https://api.yelp.com/oauth2/token",
            body = list(grant_type = "client_credentials",
                        client_id = "YOUR ID",
                        client_secret = "YOUR SECRET KEY"))

#retrieve token
token <- content(v3Auth)$access_token


#extract just the price category and count the characters
#My code is unable to append the price category.
getPriceRating <- function (term){
  
  #read file
  filename <-  paste0(term,"_amenities.csv")
  businesses <- read.csv(filename)
  
  #create price_value
  businesses$price_value<- 0
  
  #extract for every business id
  for (i in 1:nrow(businesses)){
    
    #create URL
    url <- (paste0("https://api.yelp.com/v3/businesses/",businesses$id[i])) 
    
    #request data
    res <- GET(url, add_headers('Authorization' = paste("bearer", token)))
    
    #fill in the value
    if (!is.null(content(res)$price)){
      businesses$price_value[i] <- nchar(content(res)$price)
    }  else{
      businesses$price_value[i] <- NA
    }
  }
  
  #write your results
  write.csv(businesses,file=filename,row.names=FALSE)
}



