package com.ship.management.specification;

import com.ship.management.dto.ShipQueryDTO;
import com.ship.management.entity.Ship;
import com.ship.management.entity.User;
import jakarta.persistence.criteria.*;
import org.springframework.data.jpa.domain.Specification;

public class ShipSpecification {

    public static Specification<Ship> withQuery(ShipQueryDTO queryDTO) {
        return (root, query, criteriaBuilder) -> {
            Predicate predicate = criteriaBuilder.conjunction();

            // Filter by name if provided
            if (queryDTO.getName() != null && !queryDTO.getName().trim().isEmpty()) {
                predicate = criteriaBuilder.and(predicate,
                    criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("name")),
                        "%" + queryDTO.getName().trim().toLowerCase() + "%"
                    )
                );
            }

            // Filter by company ID if provided (for admin use)
            if (queryDTO.getCompanyId() != null) {
                predicate = criteriaBuilder.and(predicate,
                    criteriaBuilder.equal(root.get("company").get("id"), queryDTO.getCompanyId())
                );
            }

            return predicate;
        };
    }

    public static Specification<Ship> withCompanyId(Long companyId) {
        return (root, query, criteriaBuilder) -> {
            if (companyId == null) {
                return criteriaBuilder.conjunction();
            }
            return criteriaBuilder.equal(root.get("company").get("id"), companyId);
        };
    }

    public static Specification<Ship> withUserId(Long userId) {
        return (root, query, criteriaBuilder) -> {
            if (userId == null) {
                return criteriaBuilder.conjunction();
            }
            Join<Ship, User> userJoin = root.join("users", JoinType.INNER);
            return criteriaBuilder.equal(userJoin.get("id"), userId);
        };
    }

    public static Specification<Ship> withNameContaining(String name) {
        return (root, query, criteriaBuilder) -> {
            if (name == null || name.trim().isEmpty()) {
                return criteriaBuilder.conjunction();
            }
            return criteriaBuilder.like(
                criteriaBuilder.lower(root.get("name")),
                "%" + name.trim().toLowerCase() + "%"
            );
        };
    }
} 