package com.ship.management.repository;

import com.ship.management.entity.User;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
   
    Optional<User> findByEmail(String email);
    List<User> findByIdIn(List<Long> userIds);
    boolean existsByEmail(String email);

    List<User> findByCompanyId(Long companyId);
    @Query("SELECT u FROM User u WHERE LOWER(u.fullName) LIKE LOWER(CONCAT('%', :search, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<User> findAllBySearch (String search, Pageable pageable);

}
