package com.fieldnotes.repository;

import com.fieldnotes.model.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, String> {
    List<Customer> findByUserIdAndDeletedFalseOrderByNameAsc(Long userId);
    Optional<Customer> findByIdAndUserId(String id, Long userId);
    List<Customer> findByUserIdAndUpdatedAtAfter(Long userId, Instant updatedAt);
    List<Customer> findByUserId(Long userId);
}
