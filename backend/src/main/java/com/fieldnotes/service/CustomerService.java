package com.fieldnotes.service;

import com.fieldnotes.dto.CustomerDto;
import com.fieldnotes.model.Customer;
import com.fieldnotes.model.User;
import com.fieldnotes.repository.CustomerRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class CustomerService {

    private final CustomerRepository customerRepository;

    public CustomerService(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    @Transactional(readOnly = true)
    public List<CustomerDto> getAllCustomers(Long userId) {
        return customerRepository.findByUserIdAndDeletedFalseOrderByNameAsc(userId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CustomerDto getCustomerById(String id, Long userId) {
        Customer customer = customerRepository.findByIdAndUserId(id, userId)
                .filter(c -> !c.isDeleted())
                .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + id));
        return toDto(customer);
    }

    @Transactional
    public CustomerDto createCustomer(CustomerDto dto, User user) {
        String id = (dto.getId() != null && !dto.getId().isBlank()) ? dto.getId() : UUID.randomUUID().toString();
        Customer customer = new Customer(
                id,
                user,
                dto.getName(),
                dto.getContactInformation()
        );
        if (dto.getCreatedAt() != null) {
            customer.setCreatedAt(dto.getCreatedAt());
        }
        if (dto.getUpdatedAt() != null) {
            customer.setUpdatedAt(dto.getUpdatedAt());
        }
        customer.setDeleted(dto.isDeleted());

        Customer saved = customerRepository.save(customer);
        return toDto(saved);
    }

    @Transactional
    public CustomerDto updateCustomer(String id, CustomerDto dto, Long userId) {
        Customer customer = customerRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + id));

        customer.setName(dto.getName());
        customer.setContactInformation(dto.getContactInformation());
        customer.setDeleted(dto.isDeleted());
        customer.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : Instant.now());

        Customer updated = customerRepository.save(customer);
        return toDto(updated);
    }

    @Transactional
    public void deleteCustomer(String id, Long userId) {
        Customer customer = customerRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + id));

        customer.setDeleted(true);
        customer.setUpdatedAt(Instant.now());
        // Soft delete all sites under this customer
        customer.getSites().forEach(site -> {
            site.setDeleted(true);
            site.setUpdatedAt(Instant.now());
            site.getNotes().forEach(note -> {
                note.setDeleted(true);
                note.setUpdatedAt(Instant.now());
            });
        });
        customerRepository.save(customer);
    }

    public CustomerDto toDto(Customer customer) {
        int siteCount = 0;
        int noteCount = 0;
        if (customer.getSites() != null) {
            siteCount = (int) customer.getSites().stream().filter(s -> !s.isDeleted()).count();
            noteCount = customer.getSites().stream()
                    .filter(s -> !s.isDeleted())
                    .mapToInt(s -> s.getNotes() != null ? (int) s.getNotes().stream().filter(n -> !n.isDeleted()).count() : 0)
                    .sum();
        }

        return new CustomerDto(
                customer.getId(),
                customer.getName(),
                customer.getContactInformation(),
                siteCount,
                noteCount,
                customer.isDeleted(),
                customer.getCreatedAt(),
                customer.getUpdatedAt()
        );
    }
}
