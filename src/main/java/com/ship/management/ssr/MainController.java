package com.ship.management.ssr;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;


@Controller
@RequestMapping("")
public class MainController {
    @GetMapping("")
    public String index(HttpSession session) {
        if (session.getAttribute("email") != null) {
            return "redirect:/dashboard";
        }
        return "redirect:/login";
    }

    @GetMapping("/login")
    public String login(HttpSession session) {
        if (session.getAttribute("email") != null) {
            return "redirect:/dashboard";
        }
        return "login";
    }
    
   
    @GetMapping("/dashboard")
    public String dashboard(HttpSession session) {
        if (session.getAttribute("email") == null) {
            return "redirect:/login";
        }
        return "dashboard";
    }
    @GetMapping("/ships")
    public String ships(HttpSession session) {
        if (session.getAttribute("email") == null) {
            return "redirect:/login";
        }
        return "ships";
    }
    @GetMapping("/companies")
    public String companies() {
        return "companies";
    }
    @GetMapping("/roles")
    public String roles() {
        return "roles";
    }
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
  
    @GetMapping("/users")
    public String users(HttpSession session) {
        if (session.getAttribute("email") == null) {
            return "redirect:/login";
        }
        return "users";
    }
    @GetMapping("/reviews-ship")
    public String reviewsShip(HttpSession session) {
        if (session.getAttribute("email") == null) {
            return "redirect:/login";
        }
        return "reviews-ship";
    }
}
