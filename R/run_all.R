# Rebuild everything from the project root. Everyone:  source("R/run_all.R")  in the RStudio Console.
# M1 only, to download new readings first:  Rscript R/run_all.R --fetch
# Runs R/01_*.R ... R/07_*.R in name order (00_*.R are helpers they source), then every test.
for (f in sort(list.files("R", "^0[1-7]_.*\\.R$", full.names = TRUE))) {
  message("== ", f)
  source(f, local = new.env())
}
for (f in sort(list.files("tests", "^test_.*\\.R$", full.names = TRUE))) source(f, local = new.env())
cat("ALL OK\n")
