package sql

import (
	mysql "database/sql"
	"fmt"

	"github.com/btoll/cpss/server/app"
)

type County struct {
	Data interface{}
	Stmt map[string]string
}

func NewCounty(payload interface{}) *County {
	return &County{
		Data: payload,
		Stmt: map[string]string{
			"SELECT":     "SELECT * FROM county",
			"GET_CITIES": "SELECT %s FROM city INNER JOIN county ON city.county=county.id WHERE county.id=%d",
		},
	}
}

func (c *County) Read(db *mysql.DB) (interface{}, error) {
	countyID := c.Data.(int)
	rows, err := db.Query(fmt.Sprintf(c.Stmt["GET_CITIES"], "COUNT(city)", countyID))
	if err != nil {
		return nil, err
	}
	var count int
	for rows.Next() {
		err = rows.Scan(&count)
		if err != nil {
			return nil, err
		}
	}
	rows, err = db.Query(fmt.Sprintf(c.Stmt["GET_CITIES"], "city,zip", countyID))
	if err != nil {
		return nil, err
	}
	coll := make(app.CountyMediaCityCollection, count)
	i := 0
	for rows.Next() {
		var city string
		var zip string
		err := rows.Scan(&city, &zip)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.CountyMediaCity{
			City: &city,
			Zip:  &zip,
		}
		i++
	}
	return coll, nil
}

func (c *County) List(db *mysql.DB) (interface{}, error) {
	rows, err := db.Query(fmt.Sprintf(c.Stmt["SELECT"]))
	if err != nil {
		return nil, err
	}
	// NOTE: Normally a bad idea to hardcode the size, but we know the number
	// of counties in PA, and that isn't liable to change.
	coll := make(app.CountyMediaCollection, 67)
	i := 0
	for rows.Next() {
		var id int
		var county string
		err := rows.Scan(&id, &county)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.CountyMedia{
			ID:     id,
			County: county,
		}
		i++
	}
	return coll, nil
}
