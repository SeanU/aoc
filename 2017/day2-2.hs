import Data.List
import System.IO
import Data.List.Split

toInt a = read a :: Int 

getNums s = map toInt (splitOn "\t" s)

input path = do
    handle <- openFile path ReadMode
    contents <- hGetContents handle
    let rows = lines contents
    return (map getNums rows)

pairs :: [Int] -> [(Int, Int)]
pairs []    = []
pairs (x:xs)  = (pairWith x xs) ++ (pairs xs)

pairWith :: Int -> [Int] -> [(Int, Int)]
pairWith x [] = []
pairWith x xs = map (\y -> (x, y)) xs

findQuotient :: [(Int, Int)] -> Int
findQuotient []         = 0
findQuotient ((a, b):xs)
    | (rem a b) == 0    = quot a b
    | (rem b a) == 0    = quot b a
    | otherwise         = findQuotient xs

quotsum path = do
    spreadsheet <- input path
    let quotients = map (findQuotient . pairs) spreadsheet
    return (sum quotients)