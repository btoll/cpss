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
			"SELECT": "SELECT * FROM county ORDER BY name",
		},
	}
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
		var name string
		err := rows.Scan(&id, &name)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.CountyMedia{
			ID:   id,
			Name: name,
		}
		i++
	}
	return coll, nil
}
