package sql

import (
	mysql "database/sql"
	"fmt"
	"strconv"

	"github.com/btoll/cpss/server/app"
)

type PayHistory struct {
	Data interface{}
	Stmt map[string]string
}

func NewPayHistory(payload interface{}) *PayHistory {
	return &PayHistory{
		Data: payload,
		Stmt: map[string]string{
			"SELECT": "SELECT %s FROM pay_history %s",
		},
	}
}

func (s *PayHistory) List(db *mysql.DB) (interface{}, error) {
	id, err := strconv.Atoi(s.Data.(string))
	if err != nil {
		return false, err
	}
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", fmt.Sprintf("WHERE specialist = %d", id)))
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", fmt.Sprintf("WHERE specialist = %d", id)))
	if err != nil {
		return nil, err
	}
	coll := make(app.PayHistoryMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var specialist int
		var changeDate string
		var payrate float64
		err = rows.Scan(&id, &specialist, &changeDate, &payrate)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.PayHistoryMedia{
			ID:         &id,
			Specialist: specialist,
			ChangeDate: changeDate,
			Payrate:    payrate,
		}
		i++
	}
	return coll, nil
}
