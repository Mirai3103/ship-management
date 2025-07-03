package com.ship.management.repository;

import com.ship.management.entity.Company;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface CompanyRepository extends JpaRepository<Company, Long> {

    Optional<Company> findByName(String name);
    
    Optional<Company> findByEmail(String email);
    
    List<Company> findAllByOrderByOrderNoAsc();
    Page<Company> findAllByOrderByOrderNoDesc(Pageable pageable);
} 