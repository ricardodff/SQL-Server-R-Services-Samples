test <- data.frame(id = id, a = a, b = b)

id <- rep(1:10, length.out = 20)
a <- 1:20
b <- 20:1

test_columns <- c(id = "numeric", a = "numeric", b = "numeric")

test_server_data <- RxSqlServerData(table = "test",
                                    connectionString = connection_string,
                                    colClasses = test_columns)

# get data in sql server
rxDataStep(inData = test,
           outFile = test_server_data,
           overwrite = TRUE)


# get data 

tagged_test_columns <- c(id = "numeric", a = "numeric", b = "numeric", sum_a = "numeric", sum_b = "numeric")

tagged_test_server <- RxSqlServerData(table = "tagged_test",
                                    connectionString = connection_string,
                                    colClasses = tagged_test_columns)

library(plyr)
library(dplyr)


test_function <- function(df) {

    df <- as.data.frame(df)

    print("1")
    print(head(df, 1))

    print("2")
    #res <- df %>% group_by(factor(id)) %>% summarise(sum_a = sum(a), sum_b = sum(b))

    df <- dplyr::mutate(df, sum_a = a + 2, sum_b = b + 2)

    #df$sum_a = df$a + 2
    #df$sum_b = df$b + 2

    print(df)

    #res <- summarise(group_by(df, id), sum_a = sum(a), sum_b = sum(b))

    return(df)
}


if (rxSqlServerTableExists("tagged_test", connectionString = connection_string))
    rxSqlServerDropTable("tagged_test", connectionString = connection_string)

rxDataStep(inData = test_server_data,
           outFile = tagged_test_server,
           overwrite = TRUE,
           #transformObjects = list(test = test),
           transformFunc = test_function,
           rowsPerRead = -1,
           reportProgress = 3)
