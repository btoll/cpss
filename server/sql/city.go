package sql

import (
	mysql "database/sql"
	"fmt"

	"github.com/btoll/cpss/server/app"
)

type City struct {
	Data interface{}
	Stmt map[string]string
}

func NewCity(payload interface{}) *City {
	return &City{
		Data: payload,
		Stmt: map[string]string{
			"DELETE":     "DELETE FROM city WHERE id=?",
			"INSERT":     "INSERT city SET name=?,zip=?,county_id=?,state=?",
			"SELECT":     "SELECT %s FROM city ORDER BY name %s",
			"GET_CITIES": "SELECT %s FROM city WHERE county_id=%d",
			"UPDATE":     "UPDATE city SET name=?,zip=?,county_id=?,state=? WHERE id=?",
		},
	}
}

func (c *City) Create(db *mysql.DB) (interface{}, error) {
	payload := c.Data.(*app.CityPayload)
	stmt, err := db.Prepare(c.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Name, payload.Zip, payload.CountyID, payload.State)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return int(id), nil
}

func (c *City) Read(db *mysql.DB) (interface{}, error) {
	cityID := c.Data.(int)
	rows, err := db.Query(fmt.Sprintf(c.Stmt["GET_CITIES"], "COUNT(id)", cityID))
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
	rows, err = db.Query(fmt.Sprintf(c.Stmt["GET_CITIES"], "*", cityID))
	if err != nil {
		return nil, err
	}
	coll := make(app.CityMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var name string
		var zip string
		var countyID int
		var state string
		err := rows.Scan(&id, &name, &zip, &countyID, &state)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.CityMedia{
			ID:       id,
			Name:     name,
			Zip:      zip,
			CountyID: countyID,
			State:    state,
		}
		i++
	}
	return coll, nil
}

func (c *City) Update(db *mysql.DB) (interface{}, error) {
	payload := c.Data.(*app.CityPayload)
	stmt, err := db.Prepare(c.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}
	_, err = stmt.Exec(payload.Name, payload.Zip, payload.CountyID, payload.State, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.CityMedia{
		ID:       *payload.ID,
		Name:     payload.Name,
		Zip:      payload.Zip,
		CountyID: payload.CountyID,
		State:    payload.State,
	}, nil
}

func (c *City) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(c.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := c.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (c *City) List(db *mysql.DB) (interface{}, error) {
	// page * recordsPerPage = limit
	limit := c.Data.(int) * 50
	rows, err := db.Query(fmt.Sprintf(c.Stmt["SELECT"], "COUNT(*)", ""))
	if err != nil {
		return nil, err
	}
	var totalCount int
	for rows.Next() {
		err = rows.Scan(&totalCount)
		if err != nil {
			return nil, err
		}
	}
	rows, err = db.Query(fmt.Sprintf(c.Stmt["SELECT"], "*", fmt.Sprintf("LIMIT %d,50", limit)))
	if err != nil {
		return nil, err
	}
	// Only return 50 rows at a clip.
	paging := &app.CityMediaPaging{
		Pager: &app.Pager{
			CurrentPage:    limit / 50,
			RecordsPerPage: 50,
			TotalCount:     totalCount,
		},
		Cities: make([]*app.Item, 50),
	}
	i := 0
	for rows.Next() {
		var id int
		var name string
		var zip string
		var countyID int
		var state string
		err := rows.Scan(&id, &name, &zip, &countyID, &state)
		if err != nil {
			return nil, err
		}
		paging.Cities[i] = &app.Item{
			ID:       id,
			Name:     name,
			Zip:      zip,
			CountyID: countyID,
			State:    state,
		}
		i++
	}
	return paging, nil
}
