package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
)

// LoginController implements the Login resource.
type LoginController struct {
	*goa.Controller
}

// NewLoginController creates a Login controller.
func NewLoginController(service *goa.Service) *LoginController {
	return &LoginController{Controller: service.NewController("LoginController")}
}

// Verify runs the verify action.
func (c *LoginController) Verify(ctx *app.VerifyLoginContext) error {
	// LoginController_Verify: start_implement

	rec, err := sql.VerifyPassword(ctx.Payload.Username, ctx.Payload.Password)
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.LoginMedia))

	// LoginController_Verify: end_implement
}
