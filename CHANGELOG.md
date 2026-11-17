# Changelog

Todas as mudanças relevantes deste projeto serão documentadas aqui.

O formato segue a ideia do [Keep a Changelog](https://keepachangelog.com/), com versões em ordem cronológica reversa.

## [r6] - 2026-08-15

### Added
- Adicionado relatório de dependências no `folderstamp`, detectando `stat`, `git`/Gitoxide, `pijul`, Iroh, Python + `blake3` e `ipfs`.
- Renomeado o rótulo de saída de `IPFS hash:` para `CID hash:` para cobrir IPFS, Iroh e outros ecossistemas que usam CID sem acoplar marca.
- Implementado fallback Python + `blake3` que gera CIDv1 raw/BLAKE3; o estudo CIDv0 single-block UnixFS/DAG-PB segue disponível como último fallback Python.
- Alterado `save` para armazenar novos stamps em `.meta/folderstamp/` em vez de criar `.folderstamp` na raiz.
- Adicionada migração automática de `.folderstamp` legado para `.meta/folderstamp/.folderstamp.1`, criando o próximo número disponível para novos stamps.
- Adicionada tarefa para avaliar Iroh como alternativa Rust para gerar CIDv0 e CIDv1.
- Adicionado instalador interativo para Kubo/IPFS e Gitoxide via GitHub Releases quando o usuário confirma no prompt.
- Adicionado Gitoxide como opção padrão sugerida mesmo quando Git clássico já existe, sem exigir passos manuais em sessão interativa.
- Adicionado suporte de portabilidade para BSD, macOS e Zircon/Fuchsia.
- Criado `SKILL.md` com práticas de Bash portátil, diagnósticos, dependências e documentação usadas nesta sequência de patches.
- Adicionada opção orientada para instalar Git pelo package manager ou Gitoxide via GitHub Releases quando nenhum dos dois está instalado.
- Adicionado suporte a repositórios Pijul ao lado do Git, exibindo canal atual quando `.pijul` existe.
- Adicionada instalação interativa do `stat` normal pelo package manager da plataforma; uutils/coreutils via GitHub Releases ficou como alternativa compatível em Rust, sem substituir silenciosamente o comando do sistema.
- Resumido o cabeçalho de dependências dos folderstamps em uma única linha `Tooling:`, preservando os caminhos/faltas de `stat`, Git, Gitoxide, Pijul, Iroh, Python BLAKE3 e IPFS sem transformar cada stamp em um transcript de instalador.
- Iroh passou a produzir o `CIDv1/raw/BLAKE3` padrão: o script converte seu BlobId BLAKE3 em CIDv1 usando apenas a biblioteca padrão do Python; IPFS/Kubo continua como fallback de compatibilidade.
- Adicionado instalador de Kubo/IPFS por GitHub Releases e alinhado o fallback Kubo para `--cid-version=1 --raw-leaves --hash=blake3`, produzindo o mesmo CIDv1/raw/BLAKE3 do caminho Iroh quando ambos processam um arquivo único.
- Adicionada rotação automática no armazenamento de stamps: `.folderstamp`, `.folderstamp1`, `.folderstamp2` e assim por diante, sem sobrescrever arquivos existentes.
- Adicionado filtro interno para `.git/`, `.meta/folderstamp/`, `.folderstamp*` e `.folderstampignore`, além de padrões tipo `.gitignore` no arquivo `.folderstampignore`.
- Adicionada flag `--help`/`-h` com uso, opções, rotação e regras de exclusão.
- Adicionadas sugestões de instalação por package manager para dependências ausentes em Termux, Cygwin, RedoxOS e Linux comum.
- Adicionado `.folderstamp` versionado com o stamp do ambiente atual.
- Criado `to-do.md` organizado a partir do antigo `Tasks.txt`, com novas ideias de portabilidade, documentação e UX.
- Adicionado suporte explícito à detecção de plataforma para Termux, Cygwin e RedoxOS, mantendo compatibilidade com Linux padrão.
- Adicionada saída `Platform:` ao comando `folderstamp display`, facilitando debug em ambientes diferentes.
- Adicionado fallback para detalhes de armazenamento: usa `lsblk` quando disponível e recorre a `df -hP` quando `lsblk` não existe.
- Iroh/BLAKE3 passou a ser o caminho padrão de endereçamento de conteúdo; Kubo/IPFS permanece apenas como fallback compatível.
- Adicionada seleção automática de diretório de instalação no `install.sh`:
  - Termux: `${PREFIX}/bin` ou `/data/data/com.termux/files/usr/bin`.
  - Cygwin: `/usr/local/bin`.
  - RedoxOS: `${HOME}/bin`.
  - Linux padrão: `/usr/bin`.

### Changed
- Renomeado `Tasks.txt` para `to-do.md`, com checkboxes e seções temáticas.
- Mantida a versão interna do `folderstamp` em `r6`.
- Centralizada a lógica de carimbo de arquivos na função `stamp_path`, reduzindo duplicação entre os modos recursivo e não-recursivo.
- Centralizada a leitura de dados Git na função `print_git_details`, com tratamento para repositórios sem remote configurado.
- O instalador deixou de depender obrigatoriamente de `sudo`; agora usa `sudo` apenas quando o diretório de destino exige permissão elevada e o comando está disponível.
- `folderstamp` e `install.sh` passaram a ser instaláveis/executáveis diretamente, com permissão de execução versionada no Git.

### Fixed
- Evitada falha em ambientes sem `lsblk`, comuns em Termux e outros sistemas minimalistas.
- Evitada falha em ambientes sem `ipfs`, substituindo o erro por uma mensagem informativa.
- Evitada falha ao exibir informações Git quando o repositório não possui remote configurado.
- Evitada dependência rígida de `/usr/bin`, que não é o destino correto em Termux, Cygwin ou RedoxOS.

## [r5] - Antes de 2026-08-15

### Existing
- Exibição do diretório atual.
- Exibição de informações de armazenamento via `lsblk` em Linux.
- Exibição da branch Git atual e primeiro remote quando `.git` existe.
- Suporte aos comandos `display` e `save`.
- Suporte ao modo recursivo com `--recursive` ou `-r`.
- Geração de hash IPFS usando `ipfs add -q --only-hash`.
