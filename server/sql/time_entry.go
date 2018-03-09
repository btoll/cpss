package sql

import (
	mysql "database/sql"
	"fmt"
	"math"

	"github.com/btoll/cpss/server/app"
)

type TimeEntry struct {
	Data interface{}
	Stmt map[string]string
}

func NewTimeEntry(payload interface{}) *TimeEntry {
	return &TimeEntry{
		Data: payload,
		Stmt: map[string]string{
			"DELETE": "DELETE FROM time_entry WHERE id=?",
			"INSERT": "INSERT time_entry SET specialist=?,consumer=?,serviceDate=?,serviceCode=?,hours=?,description=?,county=?,contractType=?,billingCode=?",
			"SELECT": "SELECT %s FROM time_entry %s",
			"UPDATE": "UPDATE time_entry SET specialist=?,consumer=?,serviceDate=?,serviceCode=?,hours=?,description=?,county=?,contractType=?,billingCode=? WHERE id=?",
		},
	}
}

func (s *TimeEntry) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.TimeEntryPayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Specialist, payload.Consumer, payload.ServiceDate, payload.ServiceCode, payload.Hours, payload.Description, payload.County, payload.ContractType, payload.BillingCode)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return int(id), nil
}

func (s *TimeEntry) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.TimeEntryPayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}
	_, err = stmt.Exec(payload.Specialist, payload.Consumer, payload.ServiceDate, payload.ServiceCode, payload.Hours, payload.Description, payload.County, payload.ContractType, payload.BillingCode, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.TimeEntryMedia{
		ID:           *payload.ID,
		Specialist:   payload.Specialist,
		Consumer:     payload.Consumer,
		ServiceDate:  payload.ServiceDate,
		ServiceCode:  payload.ServiceCode,
		Hours:        payload.Hours,
		Description:  payload.Description,
		County:       payload.County,
		ContractType: payload.ContractType,
		BillingCode:  payload.BillingCode,
	}, nil
}

func (s *TimeEntry) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *TimeEntry) List(db *mysql.DB) (interface{}, error) {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", ""))
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", ""))
	if err != nil {
		return nil, err
	}
	coll := make(app.TimeEntryMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var specialist int
		var consumer int
		var serviceDate string
		var serviceCode int
		var hours float64
		var description string
		var county int
		var contractType string
		var billingCode string
		err = rows.Scan(&id, &specialist, &consumer, &serviceDate, &serviceCode, &hours, &description, &county, &contractType, &billingCode)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.TimeEntryMedia{
			ID:          id,
			Specialist:  specialist,
			Consumer:    consumer,
			ServiceDate: serviceDate,
			ServiceCode: serviceCode,
			Hours:       hours,
			Description: description,
			County:      county,
			BillingCode: billingCode,
		}
		i++
	}
	return coll, nil
}

func (s *TimeEntry) Page(db *mysql.DB) (interface{}, error) {
	// page * recordsPerPage = limit
	recordsPerPage := 50
	limit := s.Data.(int) * recordsPerPage
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", ""))
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", fmt.Sprintf("LIMIT %d,%d", limit, recordsPerPage)))
	if err != nil {
		return nil, err
	}
	// Only the amount of rows equal to recordsPerPage unless the last page has been requested
	// (determined by `totalCount - limit`).
	capacity := totalCount - limit
	if capacity >= recordsPerPage {
		capacity = recordsPerPage
	}
	paging := &app.TimeEntryMediaPaging{
		Pager: &app.Pager{
			CurrentPage:    limit / recordsPerPage,
			RecordsPerPage: recordsPerPage,
			TotalCount:     totalCount,
			TotalPages:     int(math.Ceil(float64(totalCount) / float64(recordsPerPage))),
		},
		TimeEntries: make([]*app.TimeEntryItem, capacity),
	}
	i := 0
	for rows.Next() {
		var id int
		var specialist int
		var consumer int
		var serviceDate string
		var serviceCode int
		var hours float64
		var description string
		var county int
		var contractType string
		var billingCode string
		err = rows.Scan(&id, &specialist, &consumer, &serviceDate, &serviceCode, &hours, &description, &county, &contractType, &billingCode)
		if err != nil {
			return nil, err
		}
		paging.TimeEntries[i] = &app.TimeEntryItem{
			ID:          id,
			Specialist:  specialist,
			Consumer:    consumer,
			ServiceDate: serviceDate,
			ServiceCode: serviceCode,
			Hours:       hours,
			Description: description,
			County:      county,
			BillingCode: billingCode,
		}
		i++
	}
	return paging, nil
}
