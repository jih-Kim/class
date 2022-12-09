package Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import Entity.Table;

public interface TableRepository extends JpaRepository<Table, Long>{

}
