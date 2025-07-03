package com.ship.management.repository;

import com.ship.management.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RoleRepository extends JpaRepository<Role, Long> {
    
    @Modifying
    @Query("DELETE FROM Role r WHERE r.id = :id")
    void deleteById(@Param("id") Long id);
    Optional<Role> findByName(String name);
    
    List<Role> findAllByOrderByOrderNoAsc();
}
