package com.ship.management.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.ship.management.filter.SessionAuthenticationFilter;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
@Slf4j
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider(UserDetailsService userDetailsService,
            PasswordEncoder passwordEncoder) {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder);
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public AuthenticationFailureHandler authenticationFailureHandler() {
        return (request, response, exception) -> {
            String email = request.getParameter("email");
            String userAgent = request.getHeader("User-Agent");
            String clientIP = getClientIP(request);
            
            log.warn("Authentication failed for user: {} from IP: {} with User-Agent: {}. Reason: {}", 
                    email, clientIP, userAgent, exception.getMessage());
            

            log.debug("Authentication failure details: ", exception);
            

            response.sendRedirect("/login?error=true");
        };
    }
    
    private String getClientIP(jakarta.servlet.http.HttpServletRequest request) {
        String xfHeader = request.getHeader("X-Forwarded-For");
        if (xfHeader == null) {
            return request.getRemoteAddr();
        }
        return xfHeader.split(",")[0].trim();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, SessionAuthenticationFilter sessionFilter,
            AuthenticationFailureHandler authenticationFailureHandler) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(authorize -> authorize

                        .requestMatchers("/login", "/register").permitAll()
                        .requestMatchers("/api/auth/login", "/api/auth/register").permitAll()

                        .requestMatchers("/styles/**", "/js/**", "/images/**", "/favicon.ico").permitAll()

                        .requestMatchers("/**.css").permitAll()
                        .requestMatchers("/error").permitAll()

                        .anyRequest().authenticated())
                .formLogin(form -> form
                        .loginPage("/login")
                        .loginProcessingUrl("/login")
                        .defaultSuccessUrl("/dashboard")
                        .failureHandler(authenticationFailureHandler)
                        .usernameParameter("email")
                        .passwordParameter("password")
                        .permitAll())
                .rememberMe(rememberMe -> rememberMe
                        .key("a_very_secret_key") // bắt buộc, dùng để ký cookie
                        .rememberMeParameter("remember-me") // tên param trong form login
                        .rememberMeCookieName("remember-me-cookie")
                        .tokenValiditySeconds(7 * 24 * 60 * 60) // 7 ngày
                )

                .logout(logout -> logout
                        .logoutUrl("/logout")
                        .logoutSuccessUrl("/login?logout=true")
                        .invalidateHttpSession(true)
                        .deleteCookies("JSESSIONID")
                        .permitAll())
                .sessionManagement(session -> session
                        .maximumSessions(1)
                        .maxSessionsPreventsLogin(false));

        return http.build();
    }
}
