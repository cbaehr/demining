
import delimited "/Users/christianbaehr/Box Sync/demining/inputData/pre_panel.csv", clear

reshape long ntl, i(cell_id) j(year)

bys year: su ntl

collapse (mean) ntl, by(year)

twoway connect ntl year
