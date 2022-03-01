package sim.repository;

import org.springframework.data.repository.CrudRepository;
import sim.model.*;

public interface BookRepository extends CrudRepository<Book, Integer>
{

}
