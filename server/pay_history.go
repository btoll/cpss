package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
)

// PayHistoryController implements the PayHistory resource.
type PayHistoryController struct {
	*goa.Controller
}

// NewPayHistoryController creates a PayHistory controller.
func NewPayHistoryController(service *goa.Service) *PayHistoryController {
	return &PayHistoryController{Controller: service.NewController("PayHistoryController")}
}

// List runs the show action.
func (c *PayHistoryController) Show(ctx *app.ShowPayHistoryContext) error {
	// PayHistoryController_List: start_implement

	collection, err := sql.List(sql.NewPayHistory(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.PayHistoryMediaCollection))

	// PayHistoryController_Show: end_implement
}
