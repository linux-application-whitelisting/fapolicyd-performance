#include <iostream>
#include <fstream>
#include <string.h>
#include <string>
#include <vector>
#include <lmdb.h>
#include <chrono>

#define MEGABYTE (1024 * 1024)
#define E(expr) CHECK((rc = (expr)) == MDB_SUCCESS, #expr)
#define RES(err, expr) ((rc = expr) == (err) || (CHECK(!rc, #expr), 0))
#define CHECK(test, msg) ((test) ? (void)0 : ((void)fprintf(stderr, \
    "%s:%d: %s: %s\n", __FILE__, __LINE__, msg, mdb_strerror(rc)), abort()))

int main(int argc, char *argv[])
{
    MDB_txn *lt_txn;
    MDB_cursor *lt_cursor;
    MDB_dbi dbi;
    MDB_env *env;
    MDB_val key, value;

    using namespace std::chrono;
    high_resolution_clock::time_point start;
    duration<double> time_span;

    int rc, reversed;
    long xtimes;
    const char *dir;
    std::vector<std::string> database, query;
    std::string path;

    if (argc < 5) {
        std::cerr << "Usage: ./" << argv[0] << " <directory> <reversed> <xtimes> <file>" << std::endl;
        return EXIT_FAILURE;
    }
    dir = argv[1];
    reversed = std::stol(argv[2]);
    xtimes = std::stol(argv[3]);

    // query contains data to be searched in LMDB database
    std::ifstream file(argv[4]);
    while(file >> path) {
        query.push_back(path);
    }

    // database contains data inserted into LMDB database
    database = query;
    for(int i = 5; i < argc; i++) {
        std::ifstream tmp(argv[i]);
        while(tmp >> path) {
            database.push_back(path);
        }
        tmp.close();
    }

    E(mdb_env_create(&env));
    E(mdb_env_set_maxreaders(env, 4));
    E(mdb_env_set_maxdbs(env, 2));
    E(mdb_env_set_mapsize(env, 1500*MEGABYTE));
    E(mdb_env_open(env, dir, MDB_MAPASYNC | MDB_NOSYNC, 0664));

    E(mdb_txn_begin(env, NULL, 0, &lt_txn));
    E(mdb_dbi_open(lt_txn, NULL, reversed ? (MDB_CREATE | MDB_REVERSEKEY) : MDB_CREATE, &dbi));

    value.mv_data = (char *)"";
    value.mv_size = 0;
    for (auto& p : database) {
        key.mv_size = p.size();
        key.mv_data = (char *)p.c_str();
        mdb_put(lt_txn, dbi, &key, &value, 0);
    }
    E(mdb_txn_commit(lt_txn));

    E(mdb_txn_begin(env, NULL, MDB_RDONLY, &lt_txn));
    E(mdb_cursor_open(lt_txn, dbi, &lt_cursor));

    for (int j = 0; j < xtimes; j++) {

        for (auto& p : query) {
            key.mv_size = p.size();
            key.mv_data = (char *)p.c_str();

            start = high_resolution_clock::now();
            if ((rc = mdb_cursor_get(lt_cursor, &key, &value, MDB_SET_KEY))) {
                //fprintf(stderr, "Error: mdb_cursor_get().\n");
            }
            time_span = duration_cast<duration<double>>(high_resolution_clock::now() - start);
            std::cout << time_span.count() << std::endl;
       }
    }

    mdb_cursor_close(lt_cursor);
    mdb_txn_abort(lt_txn);
    mdb_dbi_close(env, dbi);
    mdb_env_close(env);

    return EXIT_SUCCESS;
}
