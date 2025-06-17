package com.ship.management.repository;

import com.ship.management.entity.Ship;
import com.ship.management.entity.User;

import org.hibernate.query.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ShipRepository extends JpaRepository<Ship, Long> {

    
    Optional<Ship> findByName(String name);
    @Query("SELECT s.users FROM Ship s WHERE s.id = :shipId")

    List<User> findUsersByShipId(Long shipId);
    org.springframework.data.domain.Page<Ship> findByCompanyId(Long companyId,Pageable pageable);
    List<Ship> findByCompanyId(Long companyId);
    @Query("SELECT s FROM Ship s JOIN s.users u WHERE u.id = :userId")
    List<Ship> findByUserId(Long userId);

    @Query("SELECT s FROM Ship s JOIN s.users u WHERE u.id = :id AND s.company.id = :companyId")
    List<Ship> findByUserIdAndCompanyId(Long id, Long companyId);
}
