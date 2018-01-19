package main

import (
	"github.com/btoll/cpss/server/app"
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

// Create runs the create action.
func (c *LoginController) Create(ctx *app.CreateLoginContext) error {
	// LoginController_Create: start_implement

	// Put your logic here

	// LoginController_Create: end_implement
	res := &app.LoginMedia{}
	return ctx.OK(res)
}
