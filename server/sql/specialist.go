package sql

import (
	mysql "database/sql"
	"fmt"
	"math"

	"github.com/btoll/cpss/server/app"
)

type Specialist struct {
	Data interface{}
	Stmt map[string]string
}

func NewSpecialist(payload interface{}) *Specialist {
	return &Specialist{
		Data: payload,
		Stmt: map[string]string{
			"DELETE":             "DELETE FROM specialist WHERE id=?",
			"INSERT":             "INSERT specialist SET username=?,password=?,firstname=?,lastname=?,email=?,payrate=?,authLevel=?",
			"INSERT_PAY_HISTORY": "INSERT pay_history VALUES (NULL, ?, ?, ?)",
			"SELECT":             "SELECT %s FROM specialist %s",
			"UPDATE":             "UPDATE specialist SET username=?,password=?,firstname=?,lastname=?,email=?,payrate=?,authLevel=? WHERE id=?",
		},
	}
}

// Add an entry to the pay_history table with the initial payrate.
func (s *Specialist) AddPayHistoryEntry(db *mysql.DB, id int64, payrate float64) error {
	stmt, err := db.Prepare(s.Stmt["INSERT_PAY_HISTORY"])
	if err != nil {
		return err
	}
	_, err = stmt.Exec(id, getToday(), payrate)
	if err != nil {
		return err
	}
	return nil
}

func (s *Specialist) CollectRows(rows *mysql.Rows, coll []*app.SpecialistItem) error {
	i := 0
	for rows.Next() {
		var id int
		var username string
		var password string
		var firstname string
		var lastname string
		var email string
		var payrate float64
		var authLevel int
		err := rows.Scan(&id, &username, &password, &firstname, &lastname, &email, &payrate, &authLevel)
		if err != nil {
			return err
		}
		coll[i] = &app.SpecialistItem{
			ID:        id,
			Username:  username,
			Password:  password,
			Firstname: firstname,
			Lastname:  lastname,
			Email:     email,
			Payrate:   payrate,
			AuthLevel: authLevel,
		}
		i++
	}
	return nil
}

func (s *Specialist) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.SpecialistPayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	saltedHash := SaltAndHash(payload.Password)
	res, err := stmt.Exec(payload.Username, saltedHash, payload.Firstname, payload.Lastname, payload.Email, payload.Payrate, payload.AuthLevel)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	if err = s.AddPayHistoryEntry(db, id, payload.Payrate); err != nil {
		return -1, err
	}
	return &app.SpecialistMedia{
		ID:        int(id),
		Username:  payload.Username,
		Password:  string(saltedHash),
		Firstname: payload.Firstname,
		Lastname:  payload.Lastname,
		Email:     payload.Email,
		Payrate:   payload.Payrate,
		AuthLevel: payload.AuthLevel,
	}, nil
}

func (s *Specialist) Read(db *mysql.DB) (interface{}, error) {
	row, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", fmt.Sprintf("WHERE id=%d", s.Data.(int))))
	if err != nil {
		return nil, err
	}
	var specialist *app.SpecialistMedia
	for row.Next() {
		var id int
		var username string
		var password string
		var firstname string
		var lastname string
		var email string
		var payrate float64
		var authLevel int
		err := row.Scan(&id, &username, &password, &firstname, &lastname, &email, &payrate, &authLevel)
		if err != nil {
			return nil, err
		}
		specialist = &app.SpecialistMedia{
			ID:        id,
			Username:  username,
			Password:  password,
			Firstname: firstname,
			Lastname:  lastname,
			Email:     email,
			Payrate:   payrate,
			AuthLevel: authLevel,
		}
	}
	return specialist, nil
}

func (s *Specialist) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.SpecialistPayload)
	row, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "payrate", fmt.Sprintf("WHERE id=%d", *payload.ID)))
	if err != nil {
		return nil, err
	}
	var payrate float64
	for row.Next() {
		err := row.Scan(&payrate)
		if err != nil {
			return nil, err
		}
	}
	if payrate != payload.Payrate {
		if err = s.AddPayHistoryEntry(db, int64(*payload.ID), payload.Payrate); err != nil {
			return nil, err
		}
	}
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}
	_, err = stmt.Exec(payload.Username, payload.Password, payload.Firstname, payload.Lastname, payload.Email, payload.Payrate, payload.AuthLevel, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.SpecialistMedia{
		ID:        *payload.ID,
		Username:  payload.Username,
		Password:  payload.Password,
		Firstname: payload.Firstname,
		Lastname:  payload.Lastname,
		Email:     payload.Email,
		Payrate:   payload.Payrate,
		AuthLevel: payload.AuthLevel,
	}, nil
}

func (s *Specialist) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *Specialist) List(db *mysql.DB) (interface{}, error) {
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
	coll := make([]*app.SpecialistItem, count)
	err = s.CollectRows(rows, coll)
	if err != nil {
		return nil, err
	}
	return coll, nil
}

func (s *Specialist) Page(db *mysql.DB) (interface{}, error) {
	query := s.Data.(*PageQuery)
	limit := query.Page * RecordsPerPage
	whereClause := ""
	if query.WhereClause != "" {
		whereClause = fmt.Sprintf("WHERE %s", query.WhereClause)
	}
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", whereClause))
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", fmt.Sprintf("%s LIMIT %d,%d", whereClause, limit, RecordsPerPage)))
	if err != nil {
		return nil, err
	}
	// Only the amount of rows equal to RecordsPerPage unless the last page has been requested
	// (determined by `totalCount - limit`).
	capacity := totalCount - limit
	if capacity >= RecordsPerPage {
		capacity = RecordsPerPage
	}
	paging := &app.SpecialistMediaPaging{
		Pager: &app.Pager{
			CurrentPage:    limit / RecordsPerPage,
			RecordsPerPage: RecordsPerPage,
			TotalCount:     totalCount,
			TotalPages:     int(math.Ceil(float64(totalCount) / float64(RecordsPerPage))),
		},
		Users: make([]*app.SpecialistItem, capacity),
	}
	err = s.CollectRows(rows, paging.Users)
	if err != nil {
		return nil, err
	}
	return paging, nil
}
